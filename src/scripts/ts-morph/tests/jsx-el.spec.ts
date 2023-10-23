import { transformBase } from "../src/jsx-el";

const transform = transformBase("div", "foo");
const transform2 = transformBase("div", "a");

test("no jsx", async () => {
  const file = await transform("return 1");

  expect(file.getFullText()).toEqual("return 1");
});

test("basic element", async () => {
  const file = await transform("const Foo = () => <div>Foo</div>");

  expect(file.getFullText()).toEqual("const Foo = () => <foo>Foo</foo>");
});

test("self-closing element with props", async () => {
  const file = await transform(`const Foo = () => <div bar={1} baz="2" />`);

  expect(file.getFullText()).toEqual(
    `const Foo = () => <foo bar={1} baz="2" />`
  );
});

test("element with expression props", async () => {
  const file = await transform(
    `const Foo = () => <div bar={"baz"} a={1 + 2}>Foo</div>`
  );

  expect(file.getFullText()).toEqual(
    `const Foo = () => <foo bar={"baz"} a={1 + 2}>Foo</foo>`
  );
});

test("element with string props", async () => {
  const file = await transform(`const Foo = () => <div bar="baz">Foo</div>`);

  expect(file.getFullText()).toEqual(
    `const Foo = () => <foo bar="baz">Foo</foo>`
  );
});

test("different element", async () => {
  const file = await transform(`const Foo = () => <foo><a>Foo</a></foo>`);

  expect(file.getFullText()).toEqual(`const Foo = () => <foo><a>Foo</a></foo>`);
});

test("simple replace", async () => {
  const file = await transform2(`const Foo = () => { return <div>Foo</div>; }`);

  expect(file.getFullText()).toEqual(
    `const Foo = () => { return <a>Foo</a>; }`
  );
});

test("wrapped components", async () => {
  const file = await transform2(
    `const Foo = () => { return <div>Foo<span><div foo="bar">Bar</div></span></div>; }`
  );

  expect(file.getFullText()).toEqual(
    `const Foo = () => { return <a>Foo<span><a foo="bar">Bar</a></span></a>; }`
  );
});
