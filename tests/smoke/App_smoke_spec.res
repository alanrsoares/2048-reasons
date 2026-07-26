// tests/smoke/App_smoke_spec.res - Smoke Test Spec for App component render integrity

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

describe("2048 App Smoke Test Suite", () => {
  test("App root component initializes state cleanly", () => {
    let initialScore = App.getInitialBestScore()
    expect(initialScore >= 0)->toBe(true)
  })
})
