from iris import Iris, IrisValue

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

@iris.register("what vars")
def what_vars():
    return iris.env.keys()

iris.env["my_list"] = [1,2,3,4,5]
iris.env["my_num"] = 3
