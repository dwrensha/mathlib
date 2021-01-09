/-
Copyright (c) 2021 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta
-/
import category_theory.over
import category_theory.limits.preserves.basic
import category_theory.limits.creates
import category_theory.limits.shapes.binary_products
import category_theory.monad.algebra

noncomputable theory

universes v u -- declare the `v`'s first; see `category_theory.category` for an explanation

namespace category_theory
open category limits

variables {C : Type u} [category.{v} C] (X : C)

section

open comonad
variable [has_binary_products C]

@[simps]
instance : comonad (prod.functor.obj X) :=
{ ε := { app := λ Y, limits.prod.snd },
  δ := { app := λ Y, prod.lift limits.prod.fst (𝟙 _) } }

@[simps]
def coalgebra_to_over :
  coalgebra (prod.functor.obj X) ⥤ over X :=
{ obj := λ A, over.mk (A.a ≫ limits.prod.fst),
  map := λ A₁ A₂ f, over.hom_mk f.f (by simp [←f.h_assoc]) }

@[simps]
def over_to_coalgebra :
  over X ⥤ coalgebra (prod.functor.obj X) :=
{ obj := λ f, { A := f.left, a := prod.lift f.hom (𝟙 _) },
  map := λ f₁ f₂ g, { f := g.left } }

@[simps {rhs_md := semireducible}]
def coalgebra_equiv_over :
  coalgebra (prod.functor.obj X) ≌ over X :=
{ functor := coalgebra_to_over X,
  inverse := over_to_coalgebra X,
  unit_iso := nat_iso.of_components
                (λ A, coalgebra.mk_iso (iso.refl _)
                        (prod.hom_ext (by { dsimp, simp }) (by { dsimp, simpa using A.counit })))
              (λ A₁ A₂ f, by { ext, simp }),
  counit_iso := nat_iso.of_components (λ f, over.iso_mk (iso.refl _)) (λ f g k, by tidy) }.

end

section

open monad
variable [has_binary_coproducts C]

@[simps]
instance : monad (coprod.functor.obj X) :=
{ η := { app := λ Y, coprod.inr },
  μ := { app := λ Y, coprod.desc coprod.inl (𝟙 _) } }

@[simps]
def algebra_to_under :
  monad.algebra (coprod.functor.obj X) ⥤ under X :=
{ obj := λ A, under.mk (coprod.inl ≫ A.a),
  map := λ A₁ A₂ f, under.hom_mk f.f (by { dsimp, simp [←f.h] }) }

@[simps]
def under_to_algebra :
  under X ⥤ monad.algebra (coprod.functor.obj X) :=
{ obj := λ f, { A := f.right, a := coprod.desc f.hom (𝟙 _) },
  map := λ f₁ f₂ g, { f := g.right } }

@[simps {rhs_md := semireducible}]
def algebra_equiv_under :
  monad.algebra (coprod.functor.obj X) ≌ under X :=
{ functor := algebra_to_under X,
  inverse := under_to_algebra X,
  unit_iso := nat_iso.of_components
                 (λ A, monad.algebra.mk_iso (iso.refl _)
                         (coprod.hom_ext (by tidy) (by { dsimp, simpa using A.unit.symm })))
                 (λ A₁ A₂ f, by { ext, simp }),
  counit_iso := nat_iso.of_components (λ f, under.iso_mk (iso.refl _) (by tidy)) (λ f g k, by tidy) }.

end

-- def star [has_binary_products C] : C ⥤ over X :=
-- cofree _ ⋙ coalgebra_to_over X

-- lemma forget_iso [has_binary_products C] : over_to_coalgebra X ⋙ forget _ = over.forget X :=
-- rfl

-- def forget_adj_star [has_binary_products C] : over.forget X ⊣ star X :=
-- (coalgebra_equiv_over X).symm.to_adjunction.comp _ _ (adj _)

end category_theory
