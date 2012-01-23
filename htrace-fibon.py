#!/usr/bin/env python3

import argparse
import configparser
import datetime
import fnmatch
import filecmp
import logging
import os
import subprocess
import sys
import shutil
import tempfile
import threading
import traceback
import time
import queue

Log = logging.getLogger('htrace-fibon')

class Config:
    def __init__(self, site_cfg, local_cfg, extra_cfg):
        cfg = Config.getparser()
        cfg.read_file(open(site_cfg))
        cfg.read_file(open(local_cfg))
        self.config = cfg

        extra = Config.getparser()
        extra.read_file(open(site_cfg))
        extra.read_file(open(extra_cfg))
        self.extra_config = extra

        self.known_benchmarks = set([
            "Agum",
            "BinaryTrees",
            "Blur",
            "Bzlib",
            "Chameneos",
            "Cpsa",
            "Crypto",
            "Dotp",
            "FFT2d",
            "FFT3d",
            "Fannkuch",
            "Fgl",
            "Fst",
            "Funsat",
            "Gf",
            "HaLeX",
            "Happy",
            "Hgalib",
            "Laplace",
            "MMult",
            "Mandelbrot",
            "Nbody",
            "Palindromes",
            "Pappy",
            "Pidigits",
            "Qsort",
            "QuickCheck",
            "QuickHull",
            "Regex",
            "Simgi",
            "SpectralNorm",
            "TernaryTrees",
            "Xsact",
            ])

    @property
    def benchmarks(self):
        benchmarks = []
        for sect in self.config.sections():
            if sect in self.known_benchmarks:
                sect_d = self.config[sect]
                benchmarks.append(Benchmark(sect,
                                            sect_d['configure'],
                                            sect_d['build'],
                                            sect_d['run'],
                                            sect_d['stdin'],
                                            self.fibon_benchmarks_path,
                                            self.extra_config,))
        return benchmarks

    @property
    def fibon_path(self):
        return self.config['fibon']['path']

    @property
    def fibon_benchmarks_path(self):
        return self.config['fibon']['benchmarks']

    @staticmethod
    def getparser():
        return configparser.ConfigParser(
            interpolation=configparser.ExtendedInterpolation())   

class Benchmark:
    def __init__(self, name, configure, build, run, stdin, fibon_root, extra_config):
        self.name = name
        self.configure = configure
        self.build = build
        self.run = run
        self.local_path = name + '-htrace'
        self.stdin = stdin.strip()

        # read the "extras"
        self.extra_libs  = extra_config.get(name, 'extra-libs',  fallback=None)
        self.extra_files = extra_config.get(name, 'extra-files', fallback=[])
        if self.extra_files:
            self.extra_files = self.extra_files.split()
        self.extra_ll_files = extra_config.get(name, 'extra-ll-files', fallback=[])
        if self.extra_ll_files:
            self.extra_ll_files = self.extra_ll_files.split()
        self.extra_opt_pre_link = extra_config.get(name, 'extra-opt-pre-link',
                                                   fallback=None)

        self.fibon_path = None
        for group in os.listdir(fibon_root):
            if group.startswith('_'):
                next
            path = os.path.join(fibon_root, group, name)
            if os.path.exists(path):
                self.fibon_path = path
                break

        if not self.fibon_path:
            Log.error('unable to find benchmark '+name+' in '+fibon_root)
            raise Exception('unable to find benchmark '+name+' in '+fibon_root)
    
    def __str__(self):
        return "{0}".format(self.name)

    def __repr__(self):
        return(str(self))

# Thread pool for runnin tasks concurrently
class Pool:
    def __init__(self, num_workers):
        self.num_workers = num_workers

    def run(self, tasks):
        inpq    = queue.Queue()
        statusq = queue.Queue()
        for task in tasks:
            inpq.put(task)

        for i in range(self.num_workers):
            threading.Thread(target=self.worker, args=(inpq,statusq)).start()

        status = threading.Thread(target=self.status, args=(statusq, len(tasks)))
        status.daemon = True
        status.start()

        inpq.join()

    def worker(self, q, statq):
        while not q.empty():
            task = q.get(block=True)
            task.run()
            q.task_done()
            statq.put_nowait((task.name, task.failed)) # counter of completed tasks

    def status(self, statq, total):
        # Only print status when the amount has changed
        finished = 0
        num_failed   = 0
        while finished != total:
            (name, failed) = statq.get()
            finished += 1
            if failed:
                num_failed += 1
            correct = finished - num_failed
            Log.info("Task %s finished", name)
            Log.info("%d of %d tasks finished (%6.2f%%) %d successful (%6.2f%%)",
                     finished, total, 100 * (finished/total),
                     correct, 100 * (correct/finished) )

class HtraceError(Exception):
    def __init__(self, msg):
        super(HtraceError, self).__init__(msg)
        self.msg = msg

class CommandError(Exception):
    def __init__(self, command, retcode, stdout, stderr):
        self.command = command
        self.stdout = stdout
        self.stderr = stderr
        self.retcode = retcode

    def __str__(self):
        return "Command: " + self.command.exe + "failed"

class CommandResult():
    def __init__(self, stdout, stderr):
        self.stdout = stdout
        self.stderr = stderr

class Command:
    def __init__(self, exe, args, **popen_args):
        self.exe  = exe
        self.args = args
        self.popen_args = popen_args

    def run(self):
        Log.debug("%s %s", self.exe, " ".join(self.args))
        stdoutf = tempfile.TemporaryFile('w+t')
        stderrf = tempfile.TemporaryFile('w+t')
        ret = subprocess.call([self.exe] + self.args,
                              stdout=stdoutf,
                              stderr=stderrf,
                              **self.popen_args)
        stdoutf.seek(0)
        stderrf.seek(0)

        if ret != 0:
            raise CommandError(self, ret, stdoutf, stderrf)
        return CommandResult(stdoutf, stderrf)

    def __str__(self):
        return "{0} {1}".format(self.exe, " ".join(self.args))

def run_tasks(opts, tasks):
    Pool(opts.jobs).run(tasks)
    failures = [t for t in tasks if     t.failed]
    passes   = [t for t in tasks if not t.failed]
    if len(failures) > 0:
        Log.error('Failed on %d of %d benchmarks: %s',
                  len(failures), len(tasks), failures)
    if len(passes) > 0:
        Log.info('Passed on %d of %d benchmarks: %s',
                 len(passes), len(tasks), passes)
class Task:
    def __init__(self,opts, name):
        self.name = name
        self.stdout = None
        self.stderr = None
        self.exn    = None
        self.failed = False
        self.opts   = opts

    def __repr__(self):
        return self.name

    def run(self):
        try:
            self.impl()
        except HtraceError as e:
            Log.error("Failed running task %s: %s", self.name, e.msg)
            self.failed = True
            self.exn    = e
            now         = str(datetime.datetime.now()) + '\n'
            logdir      = self.opts.logdir

            if self.stdout:
                with open(os.path.join(logdir, self.name+'.stdout'), 'w') as f:
                    f.write(now)
                    f.write(self.stdout.read())
            if self.stderr:
                with open(os.path.join(logdir, self.name+'.stderr'), 'w') as f:
                    f.write(now)
                    f.write(self.stderr.read())
            with open(os.path.join(logdir, self.name+'.exn'), 'w') as f:
                traceback.print_exc(file=f)

            if self.opts.stop_on_error:
                raise

    def impl(self):
        pass

class InitTask(Task):
    def __init__(self, opts, benchmark):
        self.benchmark = benchmark
        super(InitTask, self).__init__(opts, "init-"+str(benchmark))

    def impl(self):
        benchmark = self.benchmark

        Log.info('Initing %s', benchmark)
        args = ['init']
        local_path = os.path.join(os.path.abspath('.'), benchmark.local_path)
        bench_path = benchmark.fibon_path

        args.extend(['-o', local_path])
        args.append("--configure-args={0}".format(benchmark.configure))
        args.append("--build-args={0}".format(benchmark.build))
        run_args = benchmark.run
        if benchmark.stdin:
            run_args += ' <'+benchmark.stdin
        args.append("--run-args={0}".format(run_args))
        args.extend(['--copytree', 'Fibon'])

        if benchmark.extra_libs:
            args.append("--extra-libs={0}".format(benchmark.extra_libs))
        if benchmark.extra_ll_files:
            args.append("--extra-ll-files={0}".format(' '.join(benchmark.extra_ll_files)))
        if benchmark.extra_opt_pre_link:
            args.append("--extra-opt-pre-link={0}".format(benchmark.extra_opt_pre_link))

        cmd = Command('htrace', args, cwd=bench_path)
        try:
            cmd.run()
            self.copy_inputs(benchmark, 'all')
            self.copy_inputs(benchmark, 'train')
            self.copy_extra(benchmark)

        except CommandError as e:
            self.failed = True
            self.stdout = e.stdout
            self.stderr = e.stderr

        if self.failed:
            raise HtraceError('Failed running external command '+str(cmd)+
                              ' while trying to init benchmark '+self.benchmark.name)

    def copy_inputs(self, benchmark, input_size):
        inputs = os.path.join(benchmark.local_path,
                              'Fibon','data', input_size, 'input')

        dst = benchmark.local_path
        if os.path.exists(inputs):
            for input in os.listdir(inputs):
                src = os.path.join(inputs, input)
                Log.debug('Copying input %s to %s', src, dst)
                shutil.copy(src, dst)

    def copy_extra(self, benchmark):
        Log.debug('copying extras')
        def do_copy(base_path, extra_files, dest_fun):
            extras = map(lambda x: os.path.join(base_path, x), extra_files)
            for src in extras:
                if not os.path.exists(src):
                    raise HtraceError('Extra file '+src+' does not exist')
                dst = dest_fun(src)
                Log.debug('Copying extra %s => %s', src, dst)
                shutil.copy(src, dst)

        def local_ll_name(ll):
            """Local path to ll file, must match what the htrace script produces"""
            dirs = ll.split('/')
            while dirs.count('.'):
                dirs.remove('.')
            while dirs.count('..'):
                dirs.remove('..')
            return (os.path.join(benchmark.local_path,'bitcode', '_'.join(dirs)))

        if benchmark.extra_files:
            do_copy(benchmark.fibon_path, benchmark.extra_files,
                    lambda x: benchmark.local_path)
        if benchmark.extra_ll_files:
            do_copy(os.curdir, benchmark.extra_ll_files,
                    local_ll_name)

def init(cfg, opts):
    benchmarks = cfg.benchmarks
    tasks = [InitTask(opts, b) for b in benchmarks]
    Log.info('Init %d benchmarks: %s', len(benchmarks), benchmarks)
    run_tasks(opts, tasks)

class MakeTask(Task):
    def __init__(self, opts, benchmark, target):
        self.benchmark = benchmark
        self.target = target
        super(MakeTask, self).__init__(opts, "make-"+target+"-"+str(benchmark))

    def impl(self):
        if os.path.exists(self.benchmark.local_path):
            Log.info('Making %s for %s', self.target, self.benchmark.name)
            try:
                Command('make', [self.target], cwd=self.benchmark.local_path).run()
            except CommandError as e:
                self.failed = True
                self.stdout = e.stdout
                self.stderr = e.stderr

            if self.failed:
                raise HtraceError('Failed making benchmark '+self.benchmark.name)

def make(benchmarks, opts, target='default'):
    tasks = []
    for benchmark in benchmarks:
        if(os.path.exists(benchmark.local_path)):
           tasks.append(MakeTask(opts, benchmark, target))
    run_tasks(opts, tasks)

def build(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('building %s', benchmarks)
    make(benchmarks, opts, 'build')

def run(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('running %s', benchmarks)
    make(benchmarks, opts, 'run')

def clean(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('cleaning %s', benchmarks)
    make(benchmarks, opts, 'clean')

def erase(cfg, opts):
    benchmarks = cfg.benchmarks
    for benchmark in cfg.benchmarks:
        path = benchmark.local_path
        if os.path.exists(path):
            Log.info('Erasing %s', path)
            shutil.rmtree(path)

class InstallInfo:
    """Represents the installation info of a fibon run"""
    def __init__(self, cfg, opts):
        self.cfg  = cfg
        self.opts = opts
        self.fibon_path = cfg.fibon_path
        self.reuse = opts.reuse

        if self.reuse == None:
            raise HtraceError('InstallInfo must have reuse directory')

        self.dirs  = os.listdir(self.path)

    @property
    def path(self):
        return os.path.join(self.fibon_path, 'run', self.reuse)

    def targets(self, benchmark):
        target  = benchmark.name + '-' + self.opts.size + '-' + self.opts.tune
        return fnmatch.filter(self.dirs, target)

    def pair(self, benchmark):
        """Return the pair of files corresponding to the local and installed exes"""

        targets = self.targets(benchmark)
        if len(targets) != 1:
            Log.error('expected 1 target directory for benchmark %s, but found %d: %s',
                      benchmark.name, len(targets), targets)
        
        src = os.path.join(benchmark.local_path,
                           'build', benchmark.name)
        dst = os.path.join(self.path, targets[0],
                           'build', benchmark.name, benchmark.name)

        return (src, dst)
    
def install(cfg, opts):
    benchmarks = cfg.benchmarks
    if not opts.reuse:
        raise Exception('must specify a reuse directory for install action')

    info = InstallInfo(cfg, opts)
    if not os.path.exists(info.path):
        Log.error('install dir %s does not exist', (info.path))
        raise Exception('install dir %s does not exist' % (info.path))
    
    Log.info('installing to %s to %s', benchmarks, info.path)

    dirs = os.listdir(info.path)
    actions = []
    for benchmark in benchmarks:
        (src, dst) = info.pair(benchmark)

        if not os.path.exists(src):
            Log.error('src path %s does not exist', src)
            raise Exception('path does not exist')
        
        if not os.path.exists(dst):
            Log.error('dst path %s does not exist', dst)
            raise Exception('path does not exist')
            
        actions.append((src,dst))

    for (src,dst) in actions:
        Log.info('Copying %s => %s', src, dst)
        shutil.copyfile(src, dst)

def stat(cfg, opts):
    benchmarks = cfg.benchmarks
    info = InstallInfo(cfg, opts)

    for benchmark in benchmarks:
        (src, dst) = info.pair(benchmark)
        if filecmp.cmp(src, dst):
            Log.info('+ %s is up to date', benchmark.name)
        else:
            Log.info('- %s needs to be updated', benchmark.name)
    
def ini(cfg, opts):
    """Read a fibon config in ini format and clean it up for use with htrace"""
    def remove_unwanted_cabal_opts(cabal_opts):
        def filt(x):
            return not((x.startswith('--with-ghc='))
                       or x.startswith('--with-ghc-pkg='))
        ok = filter(filt, cabal_opts.split())
        return ' '.join(ok)

    # run fibon-run to get the fibon config in an ini format
    with tempfile.TemporaryDirectory() as tmpdir:
        try:
            fibon_run = os.path.join(cfg.fibon_path, 'dist', 'build',
                                     'fibon-run', 'fibon-run')
            fibon_cmd = (fibon_run+' -c ghc-trace -t Peak --dump-config').split()
            out = subprocess.check_output(fibon_cmd, cwd=tmpdir,
                                          stderr=subprocess.STDOUT)
        except subprocess.CalledProcessError as e:
            Log.error('Failed running fibon %s', e.output)
            raise Exception('Failed running fibon')


        # find the start of the ini output (there is some other log junk at the
        # beginning)
        lines = out.decode('utf-8').splitlines()
        for (i, line) in enumerate(lines):
            if line.startswith('['):
                ini_start = i
                break

        lines = lines[ini_start:]

        # Clean up the fibon output.
        # 1. Remove the -Train-Ref from section names
        # 2. Get rid of the --with-ghc and --with-ghc-pkg options
        ini_lines = []
        for line in lines:
            if line.startswith('['):
                if '-' in line:
                    start = line.index('-')
                    end   = line.index(']')
                    ini_lines.append(line[0:start] + line[end:])
            elif line.startswith('configure') or line.startswith('build'):
                ini_lines.append(remove_unwanted_cabal_opts(line))
            else:
                ini_lines.append(line)

        # Add the fibon section to the ini file
        ini = configparser.ConfigParser()
        ini.add_section('fibon')
        ini['fibon'] = cfg.config['fibon']
        if cfg.fibon_benchmarks_path.startswith(cfg.fibon_path):
            index   = len(cfg.fibon_path)
            bm_path = cfg.fibon_benchmarks_path[index:]
            ini['fibon']['benchmarks'] = '${path}' + bm_path

        # Read ini file from fibon output
        ini.read_string('\n'.join(ini_lines))

        # Write ini file to output
        if opts.update_ini:
            ini.write(open(opts.config, 'w'))
        else:
            ini.write(sys.stdout)

    
def parse_args(args, actions):
    parser = argparse.ArgumentParser()

    # global options
    parser.add_argument('-c', '--config', metavar='FILE',
                        default='htrace.fibon.cfg',
                        help='Read config from FILE')

    parser.add_argument('-d', '--debug', default=False, action='store_true')

    # install options
    parser.add_argument('-r', '--reuse', metavar='DIR',
                        help='Reuse directory for installing into fibon/run')
    
    parser.add_argument('-t', '--tune', metavar='Tune',
                        choices=['Base', 'Peak'], default='*',
                        help='Tune level of target install directory')
    
    parser.add_argument('-s', '--size', metavar='Size',
                        choices=['Test', 'Train', 'Ref'], default='*',
                        help='Size setting of target install directory')

    parser.add_argument('--update-ini', default=False, action='store_true',
                        help='Update the ini config file in place')

    parser.add_argument('-e', '--error-out',
                        dest='stop_on_error', default=False, action='store_true',
                        help="Stop when encountering an error")
    parser.add_argument('--logdir', metavar='LOG', default='log',
                        help='log output to dir')

    parser.add_argument('-j', '--jobs', metavar='N', default=1, type=int,
                        help='Run N tasks in parallel')

    # init, build, run
    parser.add_argument('action', choices=sorted(actions.keys()))
    return parser.parse_args()

def main(args):
    actions = {
        'init'    : lambda : init(cfg, opts),
        'clean'   : lambda : clean(cfg, opts),
        'erase'   : lambda : erase(cfg, opts),
        'build'   : lambda : build(cfg, opts),
        'run'     : lambda : run(cfg, opts),
        'install' : lambda : install(cfg, opts),
        'stat'    : lambda : stat(cfg, opts),
        'ini'     : lambda : ini(cfg, opts),
        }
    opts = parse_args(args, actions)
    site_cfg = os.path.join(os.environ['HOME'], 'local', 'bin', 'htrace.site.cfg')
    cfg  = Config(site_cfg, opts.config, 'htrace.extra.cfg')

    # configure logging
    lvl = logging.INFO
    if opts.debug:
        lvl = logging.DEBUG
    logging.basicConfig(format="[HTRACE-FIBON][{levelname}] {message}",
                        style="{", level=lvl)

    if not os.path.exists(opts.logdir):
        os.mkdir(opts.logdir)

    # perform desired action
    actions[opts.action]()

    
if __name__ == "__main__":
    main(sys.argv[1:])
