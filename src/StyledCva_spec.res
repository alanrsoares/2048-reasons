// src/StyledCva_spec.res - Spec tests for StyledCva bindings

open StyledCva

module BunTest = {
  @module("bun:test") external describe: (string, unit => unit) => unit = "describe"
  @module("bun:test") external test: (string, unit => unit) => unit = "test"

  module Expect = {
    type t
    @module("bun:test") external expect: 'a => t = "expect"
    @send external toBe: (t, 'a) => unit = "toBe"
  }
}

open BunTest
open BunTest.Expect

describe("StyledCva ReScript Bindings Spec", () => {
  test("cn merges class names properly", () => {
    let classes = cn(["text-red-500", "p-4", "text-blue-500"])
    expect(classes)->toBe("p-4 text-blue-500")
  })

  test("cva generates variant classes", () => {
    let buttonVariants = cva(
      "btn-base",
      {
        "variants": {
          "variant": {
            "primary": "btn-primary",
            "secondary": "btn-secondary",
          },
        },
      },
    )

    let cls = buttonVariants({"variant": "primary"})
    expect(cls)->toBe("btn-base btn-primary")
  })
})
