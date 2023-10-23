import { transform } from "../src/typing-react-children";
import { expectWithPrettier } from "../src/common";

// This is still in progress
// Missing tests:
//  - Interface using it already
//  - Interface extending another interface
//  - Type extending another type

test("no property in type or interface", async () => {
  const file = await transform(`
type Foo = { a: 'b' }
interface Foo { a: 'b' }
`);

  expectWithPrettier(
    file,
    `
type Foo = { a: 'b' }
interface Foo { a: 'b' }
`
  );
});

test("basic type and interface", async () => {
  const file = await transform(
    `
type Foo = { a: 'b', children: React.ReactNode }

interface Foo extends Bar { a: 'b', children: React.ReactNode }
`
  );

  expectWithPrettier(
    file,
    `
type Foo = {
a: 'b'; } & PropsWithChildren

interface Foo extends PropsWithChildren { a: 'b'; }
`
  );
});

test("type using it already", async () => {
  const file = await transform("type Foo = { a: 'b' } & PropsWithChildren");

  expectWithPrettier(file, `type Foo = { a: 'b' } & PropsWithChildren`);
});
