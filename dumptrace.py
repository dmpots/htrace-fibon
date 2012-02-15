#! /usr/bin/env python3
import struct
import pprint
import sys

class MalformedProfileException(Exception):
    pass

class Profile:
    def __init__(self):
        self.runs = []

    @staticmethod
    def parse_from(file):
        p = Profile()
        with open(file, 'rb') as f:
            buf = f.read()
            offset = 0
            while offset < len(buf):
                run = ProfileRun.parse_from(buf, offset)
                p.runs.append(run)
                offset += run.bytes
        return p

    def __repr__(self):
        return "Profile("+pprint.pformat(self.runs)+")"

    def dump(self, out):
        out.write(str(len(self.runs)) + " Runs\n")
        for (i, run) in enumerate(self.runs):
            out.write("=" * 68 + '\n')
            out.write("RUN " + str(i) + ": ")
            out.write(run.arguments + "\n")
            out.write("=" * 68 + '\n')
            for entry in run.entries:
                entry.dump(out)


class ProfileRun:
    def __init__(self):
        self.entries   = []
        self.arguments = ""
        self.bytes     = 0 # number of bytes consumed

    @staticmethod
    def parse_from(buf, offset=0):
        p = ProfileRun()
        p.parse_header(buf, offset)
        p.parse_entries(buf, offset+p.bytes)
        return p
    
    def parse_header(self, buf, offset):
        start_offset = offset
        # unpack identifier and size of arguments
        (ident, arg_size) = struct.unpack_from('ii', buf, offset)
        if ident != 1:
            err = "Invalid profile run header: " + str(ident) + "@" + str(offset)
            raise MalformedProfileException(err)
        offset += 8

        # unpack args
        (args,)  = struct.unpack_from(str(arg_size)+'s', buf, offset)
        self.arguments = str(args, "utf8")
        
        # record number of bytes read from buffer
        offset += arg_size
        if arg_size & 3:
            offset += 4 - (arg_size&3)
        self.bytes = offset - start_offset

    def parse_entries(self, buf, offset):
        start_offset = offset
        trace_id     = 0

        while (offset < len(buf)):
            # Read ProfileInfoType
            (ident,) = struct.unpack_from('I', buf, offset)

            # If this is the start of a new run so just return
            if ident == 1:
                break

            # TraceInfo
            elif ident == 9:
                offset += 4
                trace_id += 1
                trace_info = TraceProfileInfo(trace_id, buf, offset)
                offset += trace_info.parse()
                self.entries.append(trace_info)
                
            else:
                msg = "Invalid ProfileType: "+str(ident)+" @offset="+str(offset)
                raise MalformedProfileException(msg)
        
        self.bytes += offset - start_offset

        
        
    def __repr__(self):
        return (str(self.bytes)
                + "@"             
                + str(self.arguments)
                + pprint.pformat(self.entries))
    
class TraceProfileInfo:
    def __init__(self, trace_id, buf, offset):
        self.buf     = buf
        self.offset  = offset
        self.records = []
        self.hits    = 0
        self.id      = trace_id
        
    def parse(self):
        offset = self.offset
        (num_records, hits) = struct.unpack_from('IQ', self.buf, offset)
        offset += 16
        self.hits = hits
        
        for i in range(0, num_records):
            e = struct.unpack_from('II', self.buf, offset)
            self.records.append(TraceEntry(*e))
            offset += 8
        bytes_consumed = (offset - self.offset)
        return bytes_consumed

    def dump(self, out):
        h =  ""
        h += "-" * 68 + "\n"
        h += "TRACE #{0!s}: {1!s} blocks with {2!s} hits\n".format(
            self.id, len(self.records), self.hits)
        h += "{0:<10}{1:<10}{2:<10}\n".format("tag", "block", "function")
        h += "-" * 68 + "\n"
        out.write(h)

        for entry in self.records:
            if entry.tag == 0:
                tag = "-"
                (block, function) = ("", entry.payload)
            elif entry.tag == 1:
                tag = "B"
                (block, function) = (entry.payload, "")
            elif entry.tag == 2:
                tag = "H"
                (block, function) = (entry.payload, "")
            else:
                tag = "unknown"
            
            s="{0:<10}{1:<10}{2:<10}".format(tag, block, function)
            out.write(s + "\n")


class TraceEntry:
    def __init__(self, tag, payload):
        self.tag = tag
        self.payload = payload
    def __repr__(self):
        return "TraceEntry("+str(self.tag)+","+str(self.payload)+")"

    


class ProfileEntry:
    def __init__(self, callsite, target, count):
        self.callsite = callsite
        self.target   = target
        self.count    = count
    def __repr__(self):
        return "ProfileEntry("+str(self.callsite)+","+str(self.target)+","+str(self.count)+")"


if __name__ == "__main__":
    fname = "llvmprof.out"
    if len(sys.argv) > 1:
        fname = sys.argv[1]
    Profile.parse_from(fname).dump(sys.stdout)

