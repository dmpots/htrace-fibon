#!/usr/bin/env python3

import argparse
import configparser
import fnmatch
import filecmp
import logging
import os
import subprocess
import sys
import shutil

Log = logging.getLogger('htrace-fibon')

class Config:
    def __init__(self, site_cfg):
        cfg = Config.getparser()
        cfg.read_file(open(site_cfg))
        self.config = cfg

    @property
    def benchmarks(self):
        benchmarks = []
        for sect in self.config.sections():
            if sect != "fibon":
                sect_d = self.config[sect]
                benchmarks.append(Benchmark(sect,
                                            sect_d['configure'],
                                            sect_d['build'],
                                            sect_d['run'],
                                            self.config['fibon']['benchmarks']))
        return benchmarks
        
    @staticmethod
    def getparser():
        return configparser.ConfigParser(
            interpolation=configparser.ExtendedInterpolation())   

class Benchmark:
    def __init__(self, name, configure, build, run, fibon_root):
        self.name = name
        self.configure = configure
        self.build = build
        self.run = run
        self.local_path = name + '-htrace'

        self.fibon_path = None
        for group in os.listdir(fibon_root):
            if group.startswith('_'):
                next
            path = os.path.join(fibon_root, group, name)
            if os.path.exists(path):
                self.fibon_path = path
                break

        if not self.fibon_path:
            raise Exception('unable to find benchmark '+name+' in '+fibon_root)
        


    
    def __str__(self):
        return "{0}".format(self.name)

    def __repr__(self):
        return(str(self))

def init(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('initing %s', benchmarks)

    for benchmark in benchmarks:
        args = ['htrace', 'init']
        local_path = os.path.join(os.path.abspath('.'), benchmark.local_path)
        bench_path = benchmark.fibon_path
        args.extend(['-o', local_path])
        args.extend(['--configure-args', benchmark.configure])
        args.extend(['--build-args', benchmark.build])
        args.extend(['--run-args', benchmark.run])
        args.extend(['--copytree', 'Fibon'])

        try:
            Log.info('running: '+ ' '.join(args))
            subprocess.check_call(args,
                                  cwd=bench_path,
                                  stderr=subprocess.STDOUT)
            inputs = os.path.join(benchmark.local_path,
                                  'Fibon','data', 'train', 'input')

            dst = benchmark.local_path
            for input in os.listdir(inputs):
                src = os.path.join(inputs, input)
                Log.info('copying input %s to %s', src, dst)
                shutil.copy(src, dst)
                
        except subprocess.CalledProcessError as e:
            Log.error('Failed to init benchmark %s', benchmark.name)

def make(benchmarks, target='default'):
    for benchmark in benchmarks:
        Log.info('making %s for %s', target, benchmark.name)
        try:
            subprocess.check_call(['make', target], cwd=benchmark.local_path)
        except subprocess.CalledProcessError:
            Log.error('Failed making benchmark %s', benchmark.name)
    
def build(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('building %s', benchmarks)
    make(benchmarks, 'default')

def run(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('running %s', benchmarks)
    make(benchmarks, 'run')

def clean(cfg, opts):
    benchmarks = cfg.benchmarks
    Log.info('cleaning %s', benchmarks)
    make(benchmarks, 'clean')

def erase(cfg, opts):
    benchmarks = cfg.benchmarks
    for benchmark in cfg.benchmarks:
        shutil.rmtree(benchmark.local_path)

class InstallInfo:
    def __init__(self, cfg, opts):
        self.cfg  = cfg
        self.opts = opts
        self.fibon_path = cfg.config['fibon']['path']
        self.reuse = opts.reuse

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
    
    parser.add_argument('-t', '--tune', metavar='TUNE',
                        choices=['Base', 'Peak'], default='*',
                        help='Tune level of target install directory')
    
    parser.add_argument('-s', '--size', metavar='SIZE',
                        choices=['Test', 'Train', 'Ref'], default='*',
                        help='Tune level of target install directory')
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
        }
    opts = parse_args(args, actions)
    cfg  = Config(opts.config)

    # configure logging
    lvl = logging.INFO
    if opts.debug:
        lvl = logging.DEBUG
    logging.basicConfig(format="[{levelname}] {message}", style="{", level=lvl)

    # perform desired action
    actions[opts.action]()

    
if __name__ == "__main__":
    main(sys.argv[1:])
