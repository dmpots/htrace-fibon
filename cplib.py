#!/usr/bin/env python3

import argparse
import sys
import shutil
import os

htrace_fibon_dir=os.path.join(os.environ['HOME'],
                              'Research','git','htrace-fibon')
ghc_dir=os.path.join(os.environ['HOME'],
                              'Research','git','ghc-trace')

packages = {
    'base' : ['libraries/base/GHC/Base.ll',
              'libraries/base/Data/Tuple.ll',
              'libraries/base/GHC/Show.ll', 
              'libraries/base/GHC/Enum.ll', 
              'libraries/base/Data/Maybe.ll', 
              'libraries/base/GHC/List.ll', 
              'libraries/base/GHC/Num.ll', 
              'libraries/base/GHC/Real.ll', 
              'libraries/base/GHC/ST.ll', 
              'libraries/base/GHC/Arr.ll', 
              'libraries/base/GHC/Float.ll',],
              
    'prim' : ['libraries/ghc-prim/GHC/Classes.ll',
              'libraries/ghc-prim/GHC/CString.ll',
              'libraries/ghc-prim/GHC/Debug.ll',
              'libraries/ghc-prim/GHC/Generics.ll',
              'libraries/ghc-prim/GHC/IntWord64.ll',
              'libraries/ghc-prim/GHC/Magic.ll',
              'libraries/ghc-prim/GHC/Tuple.ll',
              'libraries/ghc-prim/GHC/Types.ll',],
              
    'containers' : ['libraries/containers/Data/Graph.ll',
                    'libraries/containers/Data/IntMap.ll',
                    'libraries/containers/Data/IntSet.ll',
                    'libraries/containers/Data/Map.ll',
                    'libraries/containers/Data/Sequence.ll',
                    'libraries/containers/Data/Set.ll',
                    'libraries/containers/Data/Tree.ll',],
                    
    'integer' : ['libraries/integer-simple/GHC/Integer/Logarithms/Internals.ll',
                 'libraries/integer-simple/GHC/Integer/Logarithms.ll',
                 'libraries/integer-simple/GHC/Integer/Simple/Internals.ll',
                 'libraries/integer-simple/GHC/Integer/Type.ll',
                 'libraries/integer-simple/GHC/Integer.ll',],
    }

all_ps = []
for k in sorted(packages.keys()):
    all_ps.extend(packages[k])
packages['all'] = all_ps

def parse_args(args):
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--htrace-dir', default=htrace_fibon_dir)
    parser.add_argument('-g', '--ghc-dir',    default=ghc_dir)
    parser.add_argument('-p', '--package',
                        action='append',
                        choices=sorted(packages.keys()),
                        help='copy preset group of files')
    parser.add_argument('--dry-run', action='store_true',
                        help="don't actually copy files")
    parser.add_argument('benchmark',
                        help='destination benchmark')
    parser.add_argument('files', metavar='FILE', nargs='*',
                        help='source files')


    return parser.parse_args(args)

def dest_file_name(fname):
    base = 'libraries/'
    if base in fname:
        i = fname.find(base)
        fname = fname[i+len(base):]

    fname = fname.replace('/', '_', 1)
    return fname.replace('/', '.')

def expand_source_files(opts):
    files = opts.files
    if opts.package:
        for package in opts.package:
            files = files + packages[package]
    return [os.path.join(ghc_dir, f) for f in files]

if __name__ == "__main__":

    opts = parse_args(sys.argv[1:])
    files = expand_source_files(opts)
    destd = os.path.join(opts.htrace_dir, opts.benchmark+'-htrace', 'bitcode')
    
    for ll in files:
        if not os.path.exists(ll):
            print("ERROR: {} does not exist".format(ll))
            sys.exit(1)

    if (not os.path.exists(destd)):
        print("ERROR: {} does not exist".format(destd))
        sys.exit(1)

    if len(files) > 0:
        print("Copying {} files to {}".format(len(files), destd))
        for ll in files:
            destf = dest_file_name(ll)
            dest = os.path.join(destd, destf)

            msg = "{} => {}".format(ll, destf)
            if opts.dry_run:
                msg = "PRETEND: "+msg
            print(msg)
            if not opts.dry_run:
                shutil.copyfile(ll, dest)
    else:
        print("ERROR: No files specified")
        sys.exit(1)
