--c: the card gaining effect
--reset: when the effect should disappear 
--rc: the card giving effect
--condition: condition for the effect to be "active"
--properties: properties beside EFFECT_FLAG_CLIENT_HINT
function Card.AddPiercing(c,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3208)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function Card.AddDirectAttack(c,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3205)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
--attack each monster once each
function Card.AddAdditionalAttackOnMonsterAll(c,reset,rc,value,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	--Attack all
	e1:SetDescription(3215)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	if value then e1:SetValue(value) end
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function Card.AddAdditionalAttack(c,atknum,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	if atknum==1 then e1:SetDescription(3201) end
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(atknum)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function Card.AddAdditionalAttackOnMonster(c,atknum,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	if atknum==1 then e1:SetDescription(3202) end
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(atknum)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
--ctype: card type that cannot destroy
function Card.AddCannotBeDestroyedEffect(c,ctype,reset,rc,condition,properties)
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	if ctype==TYPE_MONSTER then e1:SetDescription(3068)
	elseif ctype==TYPE_SPELL then e1:SetDescription(3069)
	elseif ctype==TYPE_TRAP then e1:SetDescription(3070)
	end
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetValue(aux.indesfilter)
	e1:SetLabel(ctype)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffectRush(e1)
end
function aux.indesfilter(e,te)
	local ctype=e:GetLabel()
	return te:IsActiveType(ctype) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function Card.AddCannotBeDestroyedBattle(c,reset,value,rc,condition,properties)
	--Cannot be destroyed battle
	local e1=nil
	if rc then 
		e1=Effect.CreateEffect(rc)
	else 
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3000)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	if value then e1:SetValue(value) else e1:SetValue(1) end
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffect(e1)
end

--Rush cost utilities
function aux.DeckMill(tp,num,reason)
	if Duel.DiscardDeck(tp,num,reason)<num then return false end 
end
--to rework with selectunselect
-- function aux.SendToGrave(tp,filter,locP1,locP2,cmin,cmax,excludec,reason,requirement)
	-- local tg=Duel.SelectMatchingCard(tp,filter,tp,locP1,locP2,cmin,cmax,excludec)
	-- if not Duel.SendtoGrave(tg,reason)==requirement then return end
-- end


--filter: filter for the group to return to the deck
-- Recursion checking and selection. (Group g) is the group to check and choose from, with a minimum (int minc) that defaults to 1 if set to nil and maximum (int maxc) that defaults to 99 if set to nil. (function rescon) is the condition to check which is needed fulfill. (int chk) is set to 0 to check and 1 to select. (int seltp) is the selecting player. (int hintmsg) is the HINTMSG that will be displayed on selection. (function cancelcon) is the condition when fulfilled allows you to end selection. (function breakcon) when fulfilled ends the selection automatically.
-- Sends a card or group (Card|Group targets) to the Deck with (int reason) as reason, if (int player) is supplied, the destination would be that player's Deck. Available seq values (SEQ_DECKTOP, SEQ_DECKBOTTOM and SEQ_DECKSHUFFLE). If SEQ_DECKSHUFFLE or other values are used for the sequence, the card is put on the top, and the Deck will be shuffled after the function resolution, except if Duel.DisableShuffleCheck() is set to true beforehand. Returns the number of cards successfully sent to the Deck.
-- reqc:number of cards required to be send to the deck
function aux.ReturnToDeck(filter,tp,loc1,loc2,ex,e,minc,maxc,rescon,chk,seltp,hintmsg,cancelcon,breakcon,cancelable,seq,reason,reqc)
	local g=Duel.GetMatchingGroup(filter,tp,loc1,loc2,ex)
	local td=aux.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,HINTMSG_SELECT)
		
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,seq,reason)>reqc then return false end
end