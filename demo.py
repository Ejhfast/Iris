from iris import Iris, IrisValue, Int, IrisType, Any
from collections import defaultdict
import fileinput

iris = Iris()

# here we simply add two integers, result will be appended to
# result list in enviornment context
@iris.register("add {n1} and {n2}")
def add(n1 : Int, n2 : Int):
    return n1+n2

# so here we add a new named variable to enviornment context that
# holds the result
@iris.register("add {n1:Int} and {n2:Int} to var")
def add_named(n1 : Int, n2 : Int):
    return IrisValue(n1+n2, name="n1_and_n2")

# demonstrate lookup of variable from environment
@iris.register("sum {lst}")
def sum1(lst : Any):
    return sum(lst)

@iris.register("count {lst}")
def count1(lst : Any):
    counts = defaultdict(int)
    for x in lst:
        counts[x] += 1
    return counts

@iris.register("make indicator for {lst}")
def make_indicator(lst : Any):
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

@iris.register("{x}")
def info(x : Any):
    return x

@iris.register("list commands")
def list_cmds():
    for k in iris.mappings.keys():
        print(k)

iris.env["my_list"] = [1,2,3,4,5]
iris.env["my_num"] = 3

# data_cols = defaultdict(list)
# lookup = {}
# for i,line in enumerate(fileinput.input()):
#     if i == 0:
#         for j,col in enumerate(line.strip().split(",")):
#             lookup[j] = col
#     else:
#         for j,d in enumerate(line.strip().split(",")):
#             data_cols[lookup[j]].append(d)
#
# for k,vs in data_cols.items():
#     iris.env[k] = vs

iris.train_model()

# iris.env_loop()
