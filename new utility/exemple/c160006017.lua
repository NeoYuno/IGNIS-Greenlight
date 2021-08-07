--鋼撃竜メタギアス
--Metagias the Steelstriking Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Make itself unable to be destroyed by battle or opponent's traps, make a 2nd attack on monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(7) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		--Effect
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			c:AddCannotBeDestroyedEffect(TYPE_TRAP,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			--Cannot be destroyed battle
			c:AddCannotBeDestroyedBattle(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			--Attack up to twice
			c:AddAdditionalAttackOnMonster(1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		end
	end
end