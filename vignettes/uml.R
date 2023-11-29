# Compile UML diagrams with the 'nomnoml' package
library(nomnoml)

nomnoml::nomnoml("
[<package>nexus|

[base::matrix||]

[NumericMatrix||]

[CompositionMatrix|
 +totals: numeric;
 +samples: character;
 +groups: character|
]

[LogRatio|
 +totals: numeric;
 +samples: character;
 +groups: character
 +parts: character;
 +ratio: character;
 +order: integer;
 +base: matrix;
 +weights: numeric|
]

[LR||]

[CLR||]

[ALR||]

[ILR||]

[PLR||]

[LogicalMatrix||]

[OutlierIndex|
 +samples: character;
 +groups: character;
 +distances: matrix;
 +limit: numeric;
 +robust: logical;
 +df: integer|
]

[base::matrix] <:- [NumericMatrix]

[NumericMatrix] <:- [CompositionMatrix]

[NumericMatrix] <:- [LogRatio]

[LogRatio] <:- [LR]
[LogRatio] <:- [CLR]
[LogRatio] <:- [ALR]
[LogRatio] <:- [ILR]
[ILR] <:- [PLR]

[base::matrix] <:- [LogicalMatrix]

[LogicalMatrix] <:- [OutlierIndex]

]
", png = "vignettes/uml.png", width = NULL, height = NULL)
