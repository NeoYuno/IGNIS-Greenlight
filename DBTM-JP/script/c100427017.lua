--白銀の城の召使い アリアンナ
--Labrynth Servant Arianna
--Scripted by Yuno
local s,id=GetID()
function s.initial_effect(c)
    --Search a "Labrynth" card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --Draw 1 card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
s.listed_series={0x27d}
--Search a "Labrynth" card
function s.filter(c)
	return c:IsSetCard(0x27d) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Draw 1 card
function s.cfilter(c,re)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and re:GetHandler():GetType()==TYPE_TRAP
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and eg:IsExists(s.cfilter,1,nil,re)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.ffilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
    local b1=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_HAND,0,1,nil)
	if (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
	    Duel.BreakEffect()
	    local ops={}
		local opval={}
		local off=1
		if b1 then
		    ops[off]=aux.Stringid(id,3)
		    opval[off-1]=1
		    off=off+1
	    end
	    if b2 then
		    ops[off]=aux.Stringid(id,4)
		    opval[off-1]=2
		    off=off+1
	    end
	    local op=Duel.SelectOption(tp,table.unpack(ops))
	    local sel=opval[op]
	    if sel==1 then
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	        local tc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	        if tc then
		        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	         end
	    else
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	        local tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	        if tc then
		        Duel.SSet(tp,tc)
			end
	    end
	end
end