import argparse
from pathlib import Path

from xdsl.printer import Printer
from xdsl.parser import Parser as IRParser

from .frontend.ir_gen import IRGen
from .frontend.parser import Parser as ToyParser
from .compiler import context
from .rewrites.optimise_toy import OptimiseToy
from .rewrites.shape_inference import ShapeInferencePass

from .interpreter import Interpreter, ToyFunctions

parser = argparse.ArgumentParser(description="Process Toy file")
parser.add_argument("source", type=Path, help="toy source file")
parser.add_argument(
    "--emit",
    dest="emit",
    choices=["ast", "ir-toy", "interpret"],
    default="ast",
    help="Action to perform on source file (default: interpret)",
)
parser.add_argument(
    "--opt", dest="opt", action="store_true", help="Optimise IR before printing"
)


def main(path: Path, emit: str, opt: bool):
    ctx = context()

    path = args.source

    with open(path, "r") as f:
        match path.suffix:
            case ".toy":
                parser = ToyParser(path, f.read())
                ast = parser.parseModule()
                if emit == "ast":
                    print(ast.dump())
                    return

                ir_gen = IRGen()
                module_op = ir_gen.ir_gen_module(ast)
            case ".mlir":
                parser = IRParser(ctx, f.read(), name=f"{path}")
                module_op = parser.parse_module()
            case _:
                print(f"Unknown file format {path}")
                return

    if emit == "ir-toy" and not opt:
        printer = Printer()
        printer.print(module_op)
        return

    OptimiseToy().apply(ctx, module_op)
    ShapeInferencePass().apply(ctx, module_op)

    if emit == "ir-toy" and opt:
        printer = Printer()
        printer.print(module_op)
        return

    if emit == "interpret":
        interpreter = Interpreter(module_op)
        interpreter.register_implementations(ToyFunctions())
        interpreter.run_module()
        return

    print(f"Unknown option {emit}")


if __name__ == "__main__":
    args = parser.parse_args()
    main(args.source, args.emit, args.opt)
