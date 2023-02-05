import { transform } from "../src/arrow-to-fn";

test("no arrow", async () => {
  const file = await transform("return 1");

  expect(file.getFullText()).toEqual("return 1");
});

test("simple replace", async () => {
  const file = await transform("() => null");

  expect(file.getFullText()).toEqual("function () { return null }");
});

test("simple replace with block", async () => {
  const file = await transform("() => { return null; }");

  expect(file.getFullText()).toEqual("function () { return null }");
});

test("simple replace with value", async () => {
  const file = await transform("() => 'foo'");

  expect(file.getFullText()).toEqual("function () { return 'foo' }");
});

test("arrow with multiple lines", async () => {
  const file = await transform(`
() => {
  const a = 1
  return a
}`);

  expect(file.getFullText()).toEqual(`
function () {
    const a = 1
    return a
}`);
});
