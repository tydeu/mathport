/-
Copyright (c) 2021 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Daniel Selsam
-/
import Lean
import Std.Data.RBMap
import Mathport.Util.String

open Lean Lean.Json
open System (FilePath)

instance : FromJson FilePath where
  fromJson? json := do
    let s : String ← fromJson? json
    pure ⟨s⟩

instance : FromJson Position where
  fromJson?
  | Json.arr a => do
    unless a.size = 2 do throw "expected an array with two elements"
    pure ⟨← fromJson? a[0], ← fromJson? a[1]⟩
  | _ => throw "JSON array expected"

instance : FromJson Unit := ⟨fun _ => ()⟩

instance {α : Type u} {β : Type v} [FromJson α] [FromJson β] : FromJson (Sum α β) :=
  ⟨fun j => (fromJson? j).map Sum.inl <|> (@fromJson? β _ j).map Sum.inr⟩

open Lean.Json in
instance [FromJson α] [BEq α] [Hashable α] : FromJson (Std.HashSet α) where
  fromJson? json := do
    let Structured.arr elems ← fromJson? json | throw "JSON array expected"
    elems.foldlM (init := {}) fun acc x => do acc.insert (← fromJson? x)

open Lean.Json in
instance [FromJson α] [BEq α] [Hashable α] [FromJson β] : FromJson (Std.HashMap α β) where
   fromJson? json := do
    let Structured.obj kvs ← fromJson? json | throw "JSON obj expected"
    kvs.foldM (init := {}) fun acc (k : String) v => do acc.insert (← fromJson? k) (← fromJson? v)
