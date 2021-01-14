/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author:  Aaron Anderson.
-/

import order.complete_boolean_algebra
import order.order_dual
import order.lattice_intervals
import order.rel_iso
import data.fintype.basic

/-!
# Atoms, Coatoms, and Simple Lattices

This module defines atoms, which are minimal non-`⊥` elements in bounded lattices, simple lattices,
which are lattices with only two elements, and related ideas.

## Main definitions

### Atoms and Coatoms
  * `is_atom a` indicates that the only element below `a` is `⊥`.
  * `is_coatom a` indicates that the only element above `a` is `⊤`.

### Atomic and Atomistic Lattices
  * `is_atomic` indicates that every element other than `⊥` is above an atom.
  * `is_coatomic` indicates that every element other than `⊤` is below a coatom.
  * `is_atomistic` indicates that every element is the `Sup` of a set of atoms.
  * `is_coatomistic` indicates that every element is the `Inf` of a set of coatoms.

### Simple Lattices
  * `is_simple_lattice` indicates that a bounded lattice has only two elements, `⊥` and `⊤`.
  * `is_simple_lattice.bounded_distrib_lattice`
  * Given an instance of `is_simple_lattice`, we provide the following definitions. These are not
    made global instances as they contain data :
    * `is_simple_lattice.boolean_algebra`
    * `is_simple_lattice.complete_lattice`
    * `is_simple_lattice.complete_boolean_algebra`

## Main results
  * `is_atom_iff_is_coatom_dual` and `is_coatom_iff_is_atom_dual` express the (definitional) duality
   of `is_atom` and `is_coatom`.
  * `is_simple_lattice_iff_is_atom_top` and `is_simple_lattice_iff_is_coatom_bot` express the
  connection between atoms, coatoms, and simple lattices

-/

variable {α : Type*}

section atoms

section is_atom

variable [order_bot α]

/-- An atom of an `order_bot` is an element with no other element between it and `⊥`,
  which is not `⊥`. -/
def is_atom (a : α) : Prop := a ≠ ⊥ ∧ (∀ b, b < a → b = ⊥)

lemma eq_bot_or_eq_of_le_atom {a b : α} (ha : is_atom a) (hab : b ≤ a) : b = ⊥ ∨ b = a :=
or.imp_left (ha.2 b) (lt_or_eq_of_le hab)

lemma is_atom.Iic {x a : α} (ha : is_atom a) (hax : a ≤ x) : is_atom (⟨a, hax⟩ : set.Iic x) :=
⟨λ con, ha.1 (subtype.mk_eq_mk.1 con), λ ⟨b, hb⟩ hba, subtype.mk_eq_mk.2 (ha.2 b hba)⟩

lemma is_atom.of_is_atom_coe_Iic {x : α} {a : set.Iic x} (ha : is_atom a) : is_atom (a : α) :=
⟨λ con, ha.1 (subtype.ext con),
  λ b hba, subtype.mk_eq_mk.1 (ha.2 ⟨b, le_trans (le_of_lt hba) a.prop⟩ hba)⟩

end is_atom

section is_coatom

variable [order_top α]

/-- A coatom of an `order_top` is an element with no other element between it and `⊤`,
  which is not `⊤`. -/
def is_coatom (a : α) : Prop := a ≠ ⊤ ∧ (∀ b, a < b → b = ⊤)

lemma eq_top_or_eq_of_coatom_le {a b : α} (ha : is_coatom a) (hab : a ≤ b) : b = ⊤ ∨ b = a :=
or.imp (ha.2 b) eq_comm.2 (lt_or_eq_of_le hab)

lemma is_coatom.Ici {x a : α} (ha : is_coatom a) (hax : x ≤ a) : is_coatom (⟨a, hax⟩ : set.Ici x) :=
⟨λ con, ha.1 (subtype.mk_eq_mk.1 con), λ ⟨b, hb⟩ hba, subtype.mk_eq_mk.2 (ha.2 b hba)⟩

lemma is_coatom.of_is_coatom_coe_Ici {x : α} {a : set.Ici x} (ha : is_coatom a) :
  is_coatom (a : α) :=
⟨λ con, ha.1 (subtype.ext con),
  λ b hba, subtype.mk_eq_mk.1 (ha.2 ⟨b, le_trans a.prop (le_of_lt hba)⟩ hba)⟩

end is_coatom

variables [bounded_lattice α] {a : α}

lemma is_atom_iff_is_coatom_dual : is_atom a ↔ is_coatom (order_dual.to_dual a) := iff.refl _

lemma is_coatom_iff_is_atom_dual : is_coatom a ↔ is_atom (order_dual.to_dual a) := iff.refl _

end atoms

section atomic

variables (α) [bounded_lattice α]

/-- A lattice is atomic iff every element other than `⊥` has an atom below it. -/
class is_atomic : Prop :=
(eq_bot_or_exists_atom_le : ∀ (b : α), b = ⊥ ∨ ∃ (a : α), is_atom a ∧ a ≤ b)

/-- A lattice is coatomic iff every element other than `⊤` has a coatom above it. -/
class is_coatomic : Prop :=
(eq_top_or_exists_le_coatom : ∀ (b : α), b = ⊤ ∨ ∃ (a : α), is_coatom a ∧ b ≤ a)

export is_atomic (eq_bot_or_exists_atom_le) is_coatomic (eq_top_or_exists_le_coatom)

variable {α}

theorem is_atomic_iff_is_coatomic_dual : is_atomic α ↔ is_coatomic (order_dual α) :=
⟨λ h, ⟨λ b, by apply h.eq_bot_or_exists_atom_le⟩, λ h, ⟨λ b, by apply h.eq_top_or_exists_le_coatom⟩⟩

theorem is_coatomic_iff_is_atomic_dual : is_coatomic α ↔ is_atomic (order_dual α) :=
⟨λ h, ⟨λ b, by apply h.eq_top_or_exists_le_coatom⟩, λ h, ⟨λ b, by apply h.eq_bot_or_exists_atom_le⟩⟩

namespace is_atomic

instance is_coatomic_dual [h : is_atomic α] : is_coatomic (order_dual α) :=
is_atomic_iff_is_coatomic_dual.1 h

variables [is_atomic α]

instance {x : α} : is_atomic (set.Iic x) :=
⟨λ ⟨y, hy⟩, (eq_bot_or_exists_atom_le y).imp subtype.mk_eq_mk.2
  (λ ⟨a, ha, hay⟩, ⟨⟨a, le_trans hay hy⟩, ha.Iic (le_trans hay hy), hay⟩)⟩

end is_atomic

namespace is_coatomic
instance is_coatomic [h : is_coatomic α] : is_atomic (order_dual α) :=
is_coatomic_iff_is_atomic_dual.1 h

variables [is_coatomic α]

instance {x : α} : is_coatomic (set.Ici x) :=
⟨λ ⟨y, hy⟩, (eq_top_or_exists_le_coatom y).imp subtype.mk_eq_mk.2
  (λ ⟨a, ha, hay⟩, ⟨⟨a, le_trans hy hay⟩, ha.Ici (le_trans hy hay), hay⟩)⟩

end is_coatomic

theorem is_atomic_iff_forall_is_atomic_Iic :
  is_atomic α ↔ ∀ (x : α), is_atomic (set.Iic x) :=
⟨@is_atomic.set.Iic.is_atomic _ _, λ h, ⟨λ x, ((@eq_bot_or_exists_atom_le _ _ (h x))
  (⊤ : set.Iic x)).imp subtype.mk_eq_mk.1 (exists_imp_exists' coe
  (λ ⟨a, ha⟩, and.imp_left (is_atom.of_is_atom_coe_Iic)))⟩⟩

theorem is_coatomic_iff_forall_is_coatomic_Ici :
  is_coatomic α ↔ ∀ (x : α), is_coatomic (set.Ici x) :=
is_coatomic_iff_is_atomic_dual.trans $ is_atomic_iff_forall_is_atomic_Iic.trans $ forall_congr
  (λ x, is_atomic_iff_is_coatomic_dual.trans iff.rfl)

end atomic

section atomistic

variables (α) [complete_lattice α]

/-- A lattice is atomistic iff every element is a `Sup` of a set of atoms. -/
class is_atomistic : Prop :=
(eq_Sup_atoms : ∀ (b : α), ∃ (s : set α), b = Sup s ∧ ∀ a, a ∈ s → is_atom a)

/-- A lattice is coatomistic iff every element is an `Inf` of a set of coatoms. -/
class is_coatomistic: Prop :=
(eq_Inf_coatoms : ∀ (b : α), ∃ (s : set α), b = Inf s ∧ ∀ a, a ∈ s → is_coatom a)

export is_atomistic (eq_Sup_atoms) is_coatomistic (eq_Inf_coatoms)

variable {α}

theorem is_atomistic_iff_is_coatomistic_dual : is_atomistic α ↔ is_coatomistic (order_dual α) :=
⟨λ h, ⟨λ b, by apply h.eq_Sup_atoms⟩, λ h, ⟨λ b, by apply h.eq_Inf_coatoms⟩⟩

theorem is_coatomistic_iff_is_atomistic_dual : is_coatomistic α ↔ is_atomistic (order_dual α) :=
⟨λ h, ⟨λ b, by apply h.eq_Inf_coatoms⟩, λ h, ⟨λ b, by apply h.eq_Sup_atoms⟩⟩

namespace is_atomistic

instance is_coatomistic_dual [h : is_atomistic α] : is_coatomistic (order_dual α) :=
is_atomistic_iff_is_coatomistic_dual.1 h

variable [is_atomistic α]

@[priority 100]
instance : is_atomic α :=
⟨λ b, by { rcases eq_Sup_atoms b with ⟨s, rfl, hs⟩,
  cases s.eq_empty_or_nonempty with h h,
  { simp [h] },
  { exact or.intro_right _ ⟨h.some, hs _ h.some_spec, le_Sup h.some_spec⟩ } } ⟩

end is_atomistic

namespace is_coatomistic

instance is_atomistic_dual [h : is_coatomistic α] : is_atomistic (order_dual α) :=
is_coatomistic_iff_is_atomistic_dual.1 h

variable [is_coatomistic α]

@[priority 100]
instance : is_coatomic α :=
⟨λ b, by { rcases eq_Inf_coatoms b with ⟨s, rfl, hs⟩,
  cases s.eq_empty_or_nonempty with h h,
  { simp [h] },
  { exact or.intro_right _ ⟨h.some, hs _ h.some_spec, Inf_le h.some_spec⟩ } } ⟩

end is_coatomistic
end atomistic

/-- A lattice is simple iff it has only two elements, `⊥` and `⊤`. -/
class is_simple_lattice (α : Type*) [bounded_lattice α] extends nontrivial α : Prop :=
(eq_bot_or_eq_top : ∀ (a : α), a = ⊥ ∨ a = ⊤)

export is_simple_lattice (eq_bot_or_eq_top)

theorem is_simple_lattice_iff_is_simple_lattice_order_dual [bounded_lattice α] :
  is_simple_lattice α ↔ is_simple_lattice (order_dual α) :=
begin
  split; intro i; haveI := i,
  { exact { exists_pair_ne := @exists_pair_ne α _,
      eq_bot_or_eq_top := λ a, or.symm (eq_bot_or_eq_top ((order_dual.of_dual a)) : _ ∨ _) } },
  { exact { exists_pair_ne := @exists_pair_ne (order_dual α) _,
      eq_bot_or_eq_top := λ a, or.symm (eq_bot_or_eq_top (order_dual.to_dual a)) } }
end

section is_simple_lattice

variables [bounded_lattice α] [is_simple_lattice α]

instance : is_simple_lattice (order_dual α) :=
is_simple_lattice_iff_is_simple_lattice_order_dual.1 (by apply_instance)

@[simp] lemma is_atom_top : is_atom (⊤ : α) :=
⟨top_ne_bot, λ a ha, or.resolve_right (eq_bot_or_eq_top a) (ne_of_lt ha)⟩

@[simp] lemma is_coatom_bot : is_coatom (⊥ : α) := is_coatom_iff_is_atom_dual.2 is_atom_top

end is_simple_lattice

namespace is_simple_lattice

variables [bounded_lattice α] [is_simple_lattice α]

/-- A simple `bounded_lattice` is also distributive. -/
@[priority 100]
instance : bounded_distrib_lattice α :=
{ le_sup_inf := λ x y z, by { rcases eq_bot_or_eq_top x with rfl | rfl; simp },
  .. (infer_instance : bounded_lattice α) }

@[priority 100]
instance : is_atomic α :=
⟨λ b, (eq_bot_or_eq_top b).imp_right (λ h, ⟨⊤, ⟨is_atom_top, ge_of_eq h⟩⟩)⟩

@[priority 100]
instance : is_coatomic α := is_coatomic_iff_is_atomic_dual.2 is_simple_lattice.is_atomic

section decidable_eq
variable [decidable_eq α]

/-- Every simple lattice is order-isomorphic to `bool`. -/
def order_iso_bool : α ≃o bool :=
{ to_fun := λ x, x = ⊤,
  inv_fun := λ x, cond x ⊤ ⊥,
  left_inv := λ x, by { rcases (eq_bot_or_eq_top x) with rfl | rfl; simp [bot_ne_top] },
  right_inv := λ x, by { cases x; simp [bot_ne_top] },
  map_rel_iff' := λ a b, begin
    rcases (eq_bot_or_eq_top a) with rfl | rfl,
    { simp [bot_ne_top] },
    { rcases (eq_bot_or_eq_top b) with rfl | rfl,
      { simp [bot_ne_top.symm, bot_ne_top, bool.ff_lt_tt] },
      { simp [bot_ne_top] } }
  end }

@[priority 200]
instance : fintype α := fintype.of_equiv bool (order_iso_bool.to_equiv).symm

/-- A simple `bounded_lattice` is also a `boolean_algebra`. -/
protected def boolean_algebra : boolean_algebra α :=
{ compl := λ x, if x = ⊥ then ⊤ else ⊥,
  sdiff := λ x y, if x = ⊤ ∧ y = ⊥ then ⊤ else ⊥,
  sdiff_eq := λ x y, by { rcases eq_bot_or_eq_top x with rfl | rfl; simp [bot_ne_top] },
  inf_compl_le_bot := λ x, by { rcases eq_bot_or_eq_top x with rfl | rfl; simp },
  top_le_sup_compl := λ x, by { rcases eq_bot_or_eq_top x with rfl | rfl; simp },
  .. is_simple_lattice.bounded_distrib_lattice }

end decidable_eq

open_locale classical

/-- A simple `bounded_lattice` is also complete. -/
protected noncomputable def complete_lattice : complete_lattice α :=
{ Sup := λ s, if ⊤ ∈ s then ⊤ else ⊥,
  Inf := λ s, if ⊥ ∈ s then ⊥ else ⊤,
  le_Sup := λ s x h, by { rcases eq_bot_or_eq_top x with rfl | rfl,
    { exact bot_le },
    { rw if_pos h } },
  Sup_le := λ s x h, by { rcases eq_bot_or_eq_top x with rfl | rfl,
    { rw if_neg,
      intro con,
      exact bot_ne_top (eq_top_iff.2 (h ⊤ con)) },
    { exact le_top } },
  Inf_le := λ s x h, by { rcases eq_bot_or_eq_top x with rfl | rfl,
    { rw if_pos h },
    { exact le_top } },
  le_Inf := λ s x h, by { rcases eq_bot_or_eq_top x with rfl | rfl,
    { exact bot_le },
    { rw if_neg,
      intro con,
      exact top_ne_bot (eq_bot_iff.2 (h ⊥ con)) } },
  .. (infer_instance : bounded_lattice α) }

/-- A simple `bounded_lattice` is also a `complete_boolean_algebra`. -/
protected noncomputable def complete_boolean_algebra : complete_boolean_algebra α :=
{ infi_sup_le_sup_Inf := λ x s, by { rcases eq_bot_or_eq_top x with rfl | rfl,
    { simp only [bot_sup_eq, ← Inf_eq_infi], apply le_refl },
    { simp only [top_sup_eq, le_top] }, },
  inf_Sup_le_supr_inf := λ x s, by { rcases eq_bot_or_eq_top x with rfl | rfl,
    { simp only [bot_inf_eq, bot_le] },
    { simp only [top_inf_eq, ← Sup_eq_supr], apply le_refl } },
  .. is_simple_lattice.complete_lattice,
  .. is_simple_lattice.boolean_algebra }

end is_simple_lattice

namespace is_simple_lattice
variables [complete_lattice α] [is_simple_lattice α]
set_option default_priority 100

instance : is_atomistic α :=
⟨λ b, (eq_bot_or_eq_top b).elim
  (λ h, ⟨∅, ⟨h.trans Sup_empty.symm, λ a ha, false.elim (set.not_mem_empty _ ha)⟩⟩)
  (λ h, ⟨{⊤}, h.trans Sup_singleton.symm, λ a ha, (set.mem_singleton_iff.1 ha).symm ▸ is_atom_top⟩)⟩

instance : is_coatomistic α := is_coatomistic_iff_is_atomistic_dual.2 is_simple_lattice.is_atomistic

end is_simple_lattice
namespace fintype
namespace is_simple_lattice
variables [bounded_lattice α] [is_simple_lattice α] [decidable_eq α]

lemma univ : (finset.univ : finset α) = {⊤, ⊥} :=
begin
  change finset.map _ (finset.univ : finset bool) = _,
  rw fintype.univ_bool,
  simp only [finset.map_insert, function.embedding.coe_fn_mk, finset.map_singleton],
  refl,
end

lemma card : fintype.card α = 2 :=
(fintype.of_equiv_card _).trans fintype.card_bool

end is_simple_lattice
end fintype

namespace bool

instance : is_simple_lattice bool :=
⟨λ a, begin
  rw [← finset.mem_singleton, or.comm, ← finset.mem_insert,
      top_eq_tt, bot_eq_ff, ← fintype.univ_bool],
  apply finset.mem_univ,
end⟩

end bool

theorem is_simple_lattice_iff_is_atom_top [bounded_lattice α] :
  is_simple_lattice α ↔ is_atom (⊤ : α) :=
⟨λ h, @is_atom_top _ _ h, λ h, {
  exists_pair_ne := ⟨⊤, ⊥, h.1⟩,
  eq_bot_or_eq_top := λ a, ((eq_or_lt_of_le (@le_top _ _ a)).imp_right (h.2 a)).symm }⟩

theorem is_simple_lattice_iff_is_coatom_bot [bounded_lattice α] :
  is_simple_lattice α ↔ is_coatom (⊥ : α) :=
is_simple_lattice_iff_is_simple_lattice_order_dual.trans is_simple_lattice_iff_is_atom_top

namespace set

theorem is_simple_lattice_Iic_iff_is_atom [bounded_lattice α] {a : α} :
  is_simple_lattice (Iic a) ↔ is_atom a :=
is_simple_lattice_iff_is_atom_top.trans $ and_congr (not_congr subtype.mk_eq_mk)
  ⟨λ h b ab, subtype.mk_eq_mk.1 (h ⟨b, le_of_lt ab⟩ ab),
    λ h ⟨b, hab⟩ hbotb, subtype.mk_eq_mk.2 (h b (subtype.mk_lt_mk.1 hbotb))⟩

theorem is_simple_lattice_Ici_iff_is_coatom [bounded_lattice α] {a : α} :
  is_simple_lattice (Ici a) ↔ is_coatom a :=
is_simple_lattice_iff_is_coatom_bot.trans $ and_congr (not_congr subtype.mk_eq_mk)
  ⟨λ h b ab, subtype.mk_eq_mk.1 (h ⟨b, le_of_lt ab⟩ ab),
    λ h ⟨b, hab⟩ hbotb, subtype.mk_eq_mk.2 (h b (subtype.mk_lt_mk.1 hbotb))⟩

end set

namespace order_iso

variables [bounded_lattice α] {β : Type*} [bounded_lattice β] (f : α ≃o β)
include f

@[simp] lemma is_atom_iff (a : α) : is_atom (f a) ↔ is_atom a :=
and_congr (not_congr ⟨λ h, f.injective (f.map_bot.symm ▸ h), λ h, f.map_bot ▸ (congr rfl h)⟩)
  ⟨λ h b hb, f.injective ((h (f b) ((f : α ↪o β).map_lt_iff.1 hb)).trans f.map_bot.symm),
  λ h b hb, f.symm.injective begin
    rw f.symm.map_bot,
    apply h,
    rw [← f.symm_apply_apply a],
    exact (f.symm : β ↪o α).map_lt_iff.1 hb,
  end⟩

@[simp] lemma is_coatom_iff (a : α) : is_coatom (f a) ↔ is_coatom a := f.dual.is_atom_iff a

lemma is_simple_lattice_iff (f : α ≃o β) : is_simple_lattice α ↔ is_simple_lattice β :=
by rw [is_simple_lattice_iff_is_atom_top, is_simple_lattice_iff_is_atom_top,
  ← f.is_atom_iff ⊤, f.map_top]

lemma is_simple_lattice [h : is_simple_lattice β] (f : α ≃o β) : is_simple_lattice α :=
f.is_simple_lattice_iff.mpr h

end order_iso
