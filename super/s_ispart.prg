FUNCTION ispart(expTest,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16)
local aExpr := {x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16}
asize(aExpr,pcount()-1)
return (ascan(aExpr,expTest)>0)

