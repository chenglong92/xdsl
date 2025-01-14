// RUN: xdsl-opt %s -p stencil-shape-inference --print-op-generic | filecheck %s


"builtin.module"() ({
  "func.func"() ({
  ^0(%0 : !stencil.field<?x?x?xf64>, %1 : !stencil.field<?x?x?xf64>):
    %3 = "stencil.cast"(%0) {"lb" = #stencil.index<-4, -4, -4>, "ub" = #stencil.index<68, 68, 68>} : (!stencil.field<?x?x?xf64>) -> !stencil.field<72x72x72xf64>
    %4 = "stencil.cast"(%1) {"lb" = #stencil.index<-4, -4, -4>, "ub" = #stencil.index<68, 68, 68>} : (!stencil.field<?x?x?xf64>) -> !stencil.field<72x72x72xf64>
    %6 = "stencil.load"(%3) : (!stencil.field<72x72x72xf64>) -> !stencil.temp<?x?x?xf64>
    %8 = "stencil.apply"(%6) ({
    ^1(%9 : !stencil.temp<?x?x?xf64>):
      %10 = "stencil.access"(%9) {"offset" = #stencil.index<-1, 0, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
      %11 = "stencil.access"(%9) {"offset" = #stencil.index<1, 0, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
      %12 = "stencil.access"(%9) {"offset" = #stencil.index<0, 1, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
      %13 = "stencil.access"(%9) {"offset" = #stencil.index<0, -1, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
      %14 = "stencil.access"(%9) {"offset" = #stencil.index<0, 0, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
      %15 = "arith.addf"(%10, %11) : (f64, f64) -> f64
      %16 = "arith.addf"(%12, %13) : (f64, f64) -> f64
      %17 = "arith.addf"(%15, %16) : (f64, f64) -> f64
      %cst = "arith.constant"() {"value" = -4.0 : f64} : () -> f64
      %18 = "arith.mulf"(%14, %cst) : (f64, f64) -> f64
      %19 = "arith.addf"(%18, %17) : (f64, f64) -> f64
      "stencil.return"(%19) : (!stencil.result<f64>) -> ()
    }) : (!stencil.temp<?x?x?xf64>) -> !stencil.temp<?x?x?xf64>
    "stencil.store"(%8, %4) {"lb" = #stencil.index<0, 0, 0>, "ub" = #stencil.index<64, 64, 64>} : (!stencil.temp<?x?x?xf64>, !stencil.field<72x72x72xf64>) -> ()
    "func.return"() : () -> ()
  }) {"function_type" = (!stencil.field<?x?x?xf64>, !stencil.field<?x?x?xf64>) -> (), "sym_name" = "stencil_hdiff"} : () -> ()
}) : () -> ()


// CHECK-NEXT: "builtin.module"() ({
// CHECK-NEXT:   "func.func"() ({
// CHECK-NEXT:   ^0(%0 : !stencil.field<?x?x?xf64>, %1 : !stencil.field<?x?x?xf64>):
// CHECK-NEXT:     %2 = "stencil.cast"(%0) {"lb" = #stencil.index<-4, -4, -4>, "ub" = #stencil.index<68, 68, 68>} : (!stencil.field<?x?x?xf64>) -> !stencil.field<72x72x72xf64>
// CHECK-NEXT:     %3 = "stencil.cast"(%1) {"lb" = #stencil.index<-4, -4, -4>, "ub" = #stencil.index<68, 68, 68>} : (!stencil.field<?x?x?xf64>) -> !stencil.field<72x72x72xf64>
// CHECK-NEXT:     %4 = "stencil.load"(%2) {"lb" = #stencil.index<-1, -1, 0>, "ub" = #stencil.index<65, 65, 64>} : (!stencil.field<72x72x72xf64>) -> !stencil.temp<66x66x64xf64>
// CHECK-NEXT:     %5 = "stencil.apply"(%4) ({
// CHECK-NEXT:     ^1(%6 : !stencil.temp<?x?x?xf64>):
// CHECK-NEXT:       %7 = "stencil.access"(%6) {"offset" = #stencil.index<-1, 0, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
// CHECK-NEXT:       %8 = "stencil.access"(%6) {"offset" = #stencil.index<1, 0, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
// CHECK-NEXT:       %9 = "stencil.access"(%6) {"offset" = #stencil.index<0, 1, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
// CHECK-NEXT:       %10 = "stencil.access"(%6) {"offset" = #stencil.index<0, -1, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
// CHECK-NEXT:       %11 = "stencil.access"(%6) {"offset" = #stencil.index<0, 0, 0>} : (!stencil.temp<?x?x?xf64>) -> f64
// CHECK-NEXT:       %12 = "arith.addf"(%7, %8) : (f64, f64) -> f64
// CHECK-NEXT:       %13 = "arith.addf"(%9, %10) : (f64, f64) -> f64
// CHECK-NEXT:       %14 = "arith.addf"(%12, %13) : (f64, f64) -> f64
// CHECK-NEXT:       %cst = "arith.constant"() {"value" = -4.0 : f64} : () -> f64
// CHECK-NEXT:       %15 = "arith.mulf"(%11, %cst) : (f64, f64) -> f64
// CHECK-NEXT:       %16 = "arith.addf"(%15, %14) : (f64, f64) -> f64
// CHECK-NEXT:       "stencil.return"(%16) : (f64) -> ()
// CHECK-NEXT:     }) {"lb" = #stencil.index<0, 0, 0>, "ub" = #stencil.index<64, 64, 64>} : (!stencil.temp<66x66x64xf64>) -> !stencil.temp<64x64x64xf64>
// CHECK-NEXT:     "stencil.store"(%5, %3) {"lb" = #stencil.index<0, 0, 0>, "ub" = #stencil.index<64, 64, 64>} : (!stencil.temp<64x64x64xf64>, !stencil.field<72x72x72xf64>) -> ()
// CHECK-NEXT:     "func.return"() : () -> ()
// CHECK-NEXT:   }) {"function_type" = (!stencil.field<?x?x?xf64>, !stencil.field<?x?x?xf64>) -> (), "sym_name" = "stencil_hdiff"} : () -> ()
// CHECK-NEXT: }) : () -> ()
