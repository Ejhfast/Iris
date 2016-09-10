from iris import Iris, IrisValue
from collections import defaultdict
import fileinput

iris = Iris()

# here we simply add two integers, result will be appended to
# result list in enviornment context
@iris.register("add {n1:Int} and {n2:Int}")
def add(n1, n2):
    return n1+n2

# so here we add a new named variable to enviornment context that
# holds the result
@iris.register("add {n1:Int} and {n2:Int} to var")
def add_named(n1, n2):
    return IrisValue(n1+n2, name="n1_and_n2")

# demonstrate lookup of variable from environment
@iris.register("sum {lst:List}")
def sum1(lst):
    return sum(lst)

@iris.register("count {lst:List}")
def count1(lst):
    counts = defaultdict(int)
    for x in lst:
        counts[x] += 1
    return counts

@iris.register("count {lst1:List} {lst2:List}")
def count2(lst1, lst2):
    out = []
    for l in [lst1, lst2]:
        out.append(count1(l))
    return out

@iris.register("make indicator for {lst:List}")
def make_indicator(lst):
    keys = set(lst)
    index2key = {i:k for i,k in enumerate(keys)}
    key2index = {k:i for i,k in index2key.items()}
    return [key2index[x] for x in lst]

@iris.register("what vars")
def what_vars():
    return iris.env.keys()

@iris.register("last values")
def last_values():
    return iris.env["results"]

@iris.register("env")
def env():
    return iris.env

@iris.register("{x:List}")
def info(x):
    return x

@iris.register("list commands")
def list_cmds():
    for k in iris.mappings.keys():
        print(k)

iris.env["my_list"] = [1,2,3,4,5]
iris.env["my_num"] = 3

data_cols = defaultdict(list)
lookup = {}
for i,line in enumerate(fileinput.input()):
    if i == 0:
        for j,col in enumerate(line.strip().split(",")):
            lookup[j] = col
    else:
        for j,d in enumerate(line.strip().split(",")):
            data_cols[lookup[j]].append(d)

for k,vs in data_cols.items():
    iris.env[k] = vs


iris.env_loop()
