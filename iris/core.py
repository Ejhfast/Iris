import shlex
import random
import dill
from .shell import IrisShell

class IrisValue:

    def __init__(self, value, name=None):
        self.value = value
        self.name = name

class Iris:

    def __init__(self):
        self.mappings = {}
        self.env = {"results":[]}

    # placeholder for something that needs to convert string input into a python value
    def magic_type_convert(self, x, type_=None):
        if x in self.env:
            return self.env[x]
        elif type_ == "Int":
            try:
                return int(x)
            except:
                raise(Exception("Expected type Int but got {}".format(x)))
        else:
            return x

    # is this word an argument?
    def is_arg(self, s):
        if len(s)>2 and s[0] == "{" and s[-1] == "}": return True
        return False

    # attempt to match query string to command and return mappings
    def arg_match(self, query_string, command_string):
        maps = {}
        query_words, cmd_words = [shlex.split(x) for x in [query_string, command_string]]
        if len(query_words) != len(cmd_words): return False, {}
        for qw, cw in zip(query_words, cmd_words):
            if self.is_arg(cw):
                word_, type_ = cw[1:-1].split(":")
                if type_ == "": type_ = None
                maps[word_] = self.magic_type_convert(qw, type_)
            else:
                if qw != cw: return False, {}
        return True, maps

    def ctx_wrap(self, func):
        def inner(*args, **kwargs):
            result = func(*args, **kwargs)
            if isinstance(result, IrisValue):
                self.env[result.name] = result.value
            else:
                self.env["results"].append(result)
            return result
        return inner

    def execute(self, query_string):
        for cmd in self.mappings.keys():
            succ, map = self.arg_match(query_string, cmd)
            if succ:
                to_execute = self.mappings[cmd]
                args = [map[arg_name] for arg_name in to_execute["args"]]
                return True, to_execute["function"](*args)
        return False, None

    def register(self, command_string):
        def inner(func):
            # sketchy hack to get function arg names CPython
            f_args = func.__code__.co_varnames[:func.__code__.co_argcount]
            self.mappings[command_string] = {"function":self.ctx_wrap(func), "args":f_args}
            return self.ctx_wrap(func)
        return inner

    def env_loop(self):
        def main_loop(x):
            try:
                succ, r = self.execute(x)
                if succ:
                    if isinstance(r, IrisValue):
                        print("\t{}".format(r.value))
                        print("\t(stored in {})".format(r.name))
                    else:
                        print("\t{}".format(r))
                else:
                    print("\tDid not match any existing command")
            except Exception as e:
                print("\tSomething went wrong: {}".format(e))
        shell = IrisShell(main_loop)
        shell.cmdloop()
