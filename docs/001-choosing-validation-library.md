# Choosing a Validation Library

## Goal

This note chooses a runtime validation library for `deno-computer`, where LLM-generated TypeScript code needs to safely process external data such as API responses, CSV rows, ERP records, and intermediate JSON.

The selection criteria are not "newest" or "most elegant". The main criterion is:

> Pick the library that LLMs have seen the most, remember the best, and are least likely to write incorrectly.

## What Runtime Validation Solves

TypeScript types only exist at compile time. They do not protect us from dirty external data at runtime.

A validation library is needed at the boundary:

```text
external data
  -> runtime validation
  -> trusted typed data
  -> business calculation
```

In Python terms, this role is similar to **Marshmallow** or **Pydantic**.

## Main Choice: Zod

Use **Zod** as the default validation library.

Why:

- Very common in the TypeScript ecosystem.
- LLMs are highly familiar with it.
- Syntax is straightforward and hard to mess up.
- Good fit for validating API responses and structured JSON.
- Automatically infers TypeScript types from schemas.
- Works well in small scripts and business-analysis pipelines.

Example:

```ts
import { z } from "zod";

const Order = z.object({
  id: z.number(),
  total: z.number(),
  createdAt: z.string(),
});

const order = Order.parse(rawOrder);
```

Decision:

```text
Default validation library: zod
```

## Alternatives

### Valibot

Valibot is also a good modern option. It is modular, type-safe, small, and has no dependencies.

Good when:

- Bundle size matters a lot.
- You want a more modular functional API.
- You are building frontend-heavy code where minimal output size matters.

Reason not to choose it first:

- LLM familiarity is probably lower than Zod.
- For this project, simplicity and LLM reliability matter more than bundle size.

### ArkType

ArkType is a powerful runtime validator designed to align closely with TypeScript's type system.

Good when:

- You want TypeScript-like syntax.
- You care about high-performance validation.
- You want strong type-level expressiveness.

Reason not to choose it first:

- More specialized mental model.
- LLMs may be less reliable when generating it.
- It is more interesting than necessary for a business-analysis runner.

### TypeBox

TypeBox builds JSON Schema objects that infer as TypeScript types.

Good when:

- You need JSON Schema compatibility.
- You are integrating with OpenAPI, Ajv, or schema-driven systems.
- You want schemas that can be shared outside TypeScript.

Reason not to choose it first:

- More schema-infrastructure oriented.
- Slightly more ceremony than Zod for simple script validation.
- Not necessary unless JSON Schema interoperability becomes important.

### io-ts

io-ts is older and functional-programming oriented.

Good when:

- You are already using fp-ts.
- You want a functional validation style.

Reason not to choose it first:

- More complex.
- More annoying for LLMs and humans to write quickly.
- Not ideal for small LLM-generated scripts.

### Yup

Yup is common in form validation, especially older React/Formik-style projects.

Good when:

- You are validating frontend forms.
- You are maintaining an existing Yup-based codebase.

Reason not to choose it first:

- Less TypeScript-first than Zod.
- Less suitable as the default schema system for a Deno/TypeScript processor runner.

## Final Decision

For `deno-computer`, use:

```bash
deno add zod
```

Final rule:

```text
Use Zod by default.
Consider Valibot only if bundle size becomes important.
Consider TypeBox only if JSON Schema / OpenAPI interoperability becomes important.
Do not start with ArkType, io-ts, or Yup for this runner.
```

## Short Version

```text
Validation: zod
Reason: most familiar to LLMs, simple syntax, TypeScript-first, good enough for business data validation.
```
