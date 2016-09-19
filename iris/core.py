import shlex
import random
import dill
from .shell import IrisShell
from sklearn.linear_model import LogisticRegression
from sklearn.feature_extraction.text import CountVectorizer
from collections import defaultdict
import numpy as np


class IrisType:
    name = "Root"

class Int(IrisType):
    name = "Int"
    def is_type(value):
        return isinstance(value, int)
    def convert_type(value, env):
        if value in env and Int.is_type(env[value]):
            return True, env[value]
        else:
            try:
                return True, int(value)
            except:
                return False, "Could not find Int type for {}".format(value)

class Any(IrisType):
    name = "Any"

class IrisValue:

    def __init__(self, value, name=None):
        self.value = value
        self.name = name

class Iris:

    def __init__(self):
        self.mappings = {}
        self.cmd2class = {}
        self.class2cmd = defaultdict(list)
        self.class_functions = {}
        self.model = LogisticRegression()
        self.vectorizer = CountVectorizer()
        self.env = {"results":[]}

    def train_model(self):
        x_docs, y = zip(*[(k, v) for k,v in self.cmd2class.items()])
        x = self.vectorizer.fit_transform(x_docs)
        self.model.fit(x,y)

    def predict_input(self, query):
        return self.model.predict_log_proba(self.vectorizer.transform([query]))

    def make_labels(self,query,cmd,succ):
        label = 0
        labels = []
        cw_words = cmd.split()
        for i,w in enumerate(query.split()):
            if i < len(cw_words) and self.is_arg(cw_words[i]) and succ:
                label += 1
                labels.append({"text":w,"index":i,"label":label})
            else:
                labels.append({"text":w,"index":i,"label":0})
        return labels

    def loop(self, query_string, arg_map):
        # first get best prediction
        predictions = self.predict_input(query_string)[0].tolist()
        sorted_predictions = sorted([(i,self.class2cmd[i],x) for i,x in enumerate(predictions)],key=lambda x: x[-1], reverse=True)
        best_class = sorted_predictions[0][0]
        to_execute = self.class_functions[best_class]
        # now check arg_map
        if all([arg_name in arg_map for arg_name in to_execute["args"]]):
            # we were given all the arguments, now do type conversion
            print(to_execute["types"])
            s_args = [self.magic_type_convert(arg_map[arg_name], to_execute["types"][arg_name]) for arg_name in to_execute["args"]]
            # this is redundant and needs to be refactored --
            # also, need at least a 3 way response value (True -- complete, False -- more args, False -- kill it)
            succs = [x[0] for x in s_args]
            args = [x[1] for x in s_args]
            if all(succs):
                return True, to_execute["function"](*args)
            else:
                return False, "I ran into a problem:\n"+"\n".join([str(x) for x in zip(["arg{}".format(i) for i in range(1,len(args)+1)],args)])
        # else we don't have all the args, so try to match
        for cmd in self.class2cmd[best_class]:
            succ, map = self.arg_match(query_string, cmd, to_execute["types"])
            if succ:
                s_args = [map[arg_name] for arg_name in to_execute["args"]]
                succs = [x[0] for x in s_args]
                args = [x[1] for x in s_args]
                print(succs,args)
                if all(succs):
                    return True, to_execute["function"](*args)
                else:
                    return False, "I ran into a problem:\n"+"\n".join([str(x) for x in zip(["arg{}".format(i) for i in range(1,len(args)+1)],args)])
        # if all that fails we need to start asking for args
        for arg_name in to_execute["args"]:
            if not (arg_name in arg_map):
                if len(arg_map) == 0: # implies this is the first argument asked for
                    return False, "I think you want to \"{}\". What is the value of {}?".format(cmd,arg_name)
                return False, "What is the value of {}?".format(arg_name)
        # this shouldn't happen
        return False, None

    def best_n(self, query, n=1):
        probs = self.model.predict_log_proba(self.vectorizer.transform([query]))[0]
        results = []
        for i,p in sorted(enumerate(probs),key=lambda x: x[1],reverse=True):
            for cmd in self.class2cmd[i]:
                succ, map = self.arg_match(query, cmd)
                if succ: break
            print(query,cmd,succ)
            labels = self.make_labels(query,cmd,succ)
            results.append({
                "class":i,
                "prob":p,
                "cmds": self.class2cmd[i],
                "args": len(self.class_functions[i]["args"]),
                "labels": labels
            })
        return results[0] # just returning one for now

    def call_class(self, class_, args):
        to_execute = self.class_functions[class_]
        num_args = max([x["label"] for x in args])
        extracted_args = []
        cmd_words = [x for x in self.class2cmd[class_][0].split() if self.is_arg(x)]
        for i,ref in zip(range(1,num_args+1),cmd_words):
            ref_type =  ref[1:-1].split(":")[1].strip()
            argi = " ".join([x["text"] for x in args if x["label"] == i])
            argt = self.magic_type_convert(argi,ref_type)
            extracted_args.append(argt)
        print(extracted_args)
        res =  to_execute["function"](*extracted_args)
        print(res)
        return res

    # placeholder for something that needs to convert string input into a python value
    def magic_type_convert(self, x, type_):
        return type_.convert_type(x,self.env)

    # is this word an argument?
    def is_arg(self, s):
        if len(s)>2 and s[0] == "{" and s[-1] == "}": return True
        return False

    def get_user_args(self, cmd):
        maps = {}
        for w in shlex.split(cmd):
            if self.is_arg(w):
                word_, type_ = w[1:-1].split(":")
                print("\tWhat is {} in the command: \"{}\"".format(w,cmd))
                data = input()
                maps[word_] = self.magic_type_convert(data.strip(),type_)
        return maps

    # attempt to match query string to command and return mappings
    def arg_match(self, query_string, command_string, types):
        maps = {}
        labels = []
        query_words, cmd_words = [shlex.split(x) for x in [query_string, command_string]]
        if len(query_words) != len(cmd_words): return False, {}
        for qw, cw in zip(query_words, cmd_words):
            if self.is_arg(cw):
                word_ = cw[1:-1]
                maps[word_] = self.magic_type_convert(qw, types[word_])
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
        predictions = self.predict_input(query_string)[0].tolist()
        sorted_predictions = sorted([(i,self.class2cmd[i],x) for i,x in enumerate(predictions)],key=lambda x: x[-1], reverse=True)
        best_class = sorted_predictions[0][0]
        to_execute = self.class_functions[best_class]
        for cmd in self.class2cmd[best_class]:
            succ, map = self.arg_match(query_string, cmd)
            if succ:
                args = [map[arg_name] for arg_name in to_execute["args"]]
                return True, to_execute["function"](*args)
        args_map = self.get_user_args(cmd)
        if args_map:
            args = [args_map[arg_name] for arg_name in to_execute["args"]]
            return True, to_execute["function"](*args)
        # for cmd in self.mappings.keys():
        #     succ, map = self.arg_match(query_string, cmd)
        #     if succ:
        #         to_execute = self.mappings[cmd]
        #         args = [map[arg_name] for arg_name in to_execute["args"]]
        #         return True, to_execute["function"](*args)
        return False, None

    def register(self, command_string):
        def inner(func):
            # sketchy hack to get function arg names CPython
            f_args = func.__code__.co_varnames[:func.__code__.co_argcount]
            f_types = func.__annotations__
            self.mappings[command_string] = {"function":self.ctx_wrap(func), "args":f_args}
            new_index = len(self.cmd2class)
            self.cmd2class[command_string] = new_index
            self.class2cmd[new_index].append(command_string)
            self.class_functions[new_index] = {"function":self.ctx_wrap(func), "args":f_args, "types":f_types}
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
