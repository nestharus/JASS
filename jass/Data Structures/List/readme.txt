Every list is represented by a special node called a head. This is also referred to as the List itself, or the
collection.

Every list may have a number of nodes, or elements.


Lists may support allocation for heads and nodes. If it does, it will be appended with an H for head or an N for node.

The allocation may either use arrays or tables. Tables have no instance limit at the cost of performance. If a head is allocated via
tables, then the H will be appended with a t. The same goes for node.

Thus the flavors are as follows

H		head allocation
N		node allocation
HN		head/node allocation
Ht		head table allocation
Nt		node table allocation
HtNt		head/node table allocation
HtN		head table allocation, node array allocation
HNt		head array allocation, node table allocation
NONE		no allocation


When the collection does not provide an allocator, it expects the head and elements to be passed in. The List allocator is specialized
to minimize code generation and maximize speed, so unless the elements already exist, the List allocator should be used.


H-N-
H-Nt-
H-N
H-Nt

Ht-N-
Ht-Nt-
Ht-N
Ht-Nt

HN-
HNt-
HN
HNt

HtN-
HtNt-
HtN
HtNt