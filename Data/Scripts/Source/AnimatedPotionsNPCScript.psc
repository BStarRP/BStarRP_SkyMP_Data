Scriptname AnimatedPotionsNPCScript extends activemagiceffect  

;Changelog:
; 5.0.0
; - Pretty much rewrote the whole script using the player animation script changes and practices
; - Instead of sheathing the weapon and waiting for it to finish, we just skip it. Maybe an option toggle to choose either option would be nice.

Import po3_SKSEFunctions
import PO3_Events_AME

GlobalVariable property ToggleNPCSlowEffect auto
GlobalVariable property NPCStaggerToggle auto
GlobalVariable property NPCStopAnimation auto
GlobalVariable property ForceNPCDrinking auto
Spell property NPCSlowEffectSP auto
Sound property NPCFastPotionSM auto
string property Eventstring auto
int InstanceID
Actor Target
form LeftItem
Spell LeftSpell



Event OnEffectStart(Actor akTarget, Actor akCaster)
    if akTarget != Game.GetPlayer()
        if TargetConditionCheck(akTarget) == true
            Target = akTarget
            NPCDrinking()
            self.Dispel()
        endif   
    endif
EndEvent
    

bool Function NPCDrinking()
    if ForceNPCDrinking.GetValueInt() == 0
        if (Target as ObjectReference).GetAnimationVariablebool("isStaggering") == true || GetActorKnockState(Target) != 0
            return false
        endif
    endif

    if WaitForTarget(Target, 8.0) == false
        return false
    endif

    bool bStopSprint = StopSprint(Target)

;/     if SheatheWeaponAndWait(Target,8) == false; Fails sheathing weapon
        if bStopSprint == true; Allow sprinting again
            Target.SetAnimationVariablebool("bSprintOK", true)
        endif
        return false
    endif /;
    Target.SheatheWeapon()
    (Target as ObjectReference).SetAnimationVariablebool("bEquipOK",false)

    RegisterForHitEventEx(self)
    Debug.SendAnimationEvent(Target as ObjectReference, Eventstring)
    InstanceID = NPCFastPotionSM.Play(Target)
    bool SlowEffect = CastSlowEffectSP(Target)
    Utility.Wait(2.4)

    if bStopSprint == true; Allow sprinting again
        (Target as ObjectReference).SetAnimationVariablebool("bSprintOK", true)
    endif

    (Target as ObjectReference).SetAnimationVariablebool("bEquipOK",true)
    Target.SheatheWeapon()
    Target.DrawWeapon()
    UnRegisterForHitEventEx(self)
    return true
EndFunction


Event OnHitEx(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    if NPCStopAnimation.GetValueint() == 1
        Sound.StopInstance(InstanceID)
        Debug.SendAnimationEvent(Target as ObjectReference, "offsetstop")
        Debug.SendAnimationEvent(Target as ObjectReference, "AnimObjectUnequip")
    endif
    if NPCStaggerToggle.GetValueint() == 1
        Debug.SendAnimationEvent(Target as ObjectReference, "StaggerStart")
    endif
EndEvent


bool Function WaitForTarget(Actor akTarget, float fMaxWaitTime)
    float fWaitTime = 0.0
    if (akTarget as ObjectReference).GetAnimationVariablebool("isStaggering") == true
        while (akTarget as ObjectReference).GetAnimationVariablebool("isStaggering") == true && fWaitTime < fMaxWaitTime
            Utility.Wait(0.1)
            fWaitTime += 0.1
        EndWhile
        if fWaitTime >= fMaxWaitTime
            return false
        endif
    elseif GetActorKnockState(Target) != 0
        while GetActorKnockState(Target) != 0 && fWaitTime < fMaxWaitTime
            Utility.Wait(0.1)
            fWaitTime += 0.1
        EndWhile
        if fWaitTime >= fMaxWaitTime
            return false
        endif
    endif
    return true
EndFunction


; Checks if the target was was allowed to sprint before drinking potion to
; not unintentionally release target from some other sprint lock.
;
; Parameters:
; - TypeActor: The actor to stop and prevent sprinting.
;
; Return Value:
; - TypeBool: Returns true if sprinting is now prevented, otherwise; false.
bool Function stopSprint(Actor akTarget)
    if (akTarget as ObjectReference).GetAnimationVariablebool("bSprintOK") == true
        (akTarget as ObjectReference).SetAnimationVariablebool("bSprintOK", false)
        return true
    endif
    return false
EndFunction


; Casts a slow effect on the specified target actor if ToggleSlowEffect is enabled.
; 
; Parameters:
; - akTarget: Actor - The target actor on which to cast the slow effect.
; 
; Return Value:
; - Bool: True if ToggleSlowEffect was enabled; otherwise, false.
bool Function CastSlowEffectSP(Actor akTarget)
    if ToggleNPCSlowEffect.GetValueint() == 1
        NPCSlowEffectSP.RemoteCast(akTarget as ObjectReference,none)
        return true
    endif

    return false
EndFunction


; Checks whether the target is not:
; - Riding a horse
; - Swimming
; - in bAnimationDriven state
; - in a killmove
; - Bleeding out
; - Not mounting or standing on/off chairs
;
; Parameters:
; - TypeActor: The actor to be checked.
;
; Return Value: 
; - TypeBool: Returns true if the target passes the checks; otherwise, returns false.
bool Function TargetConditionCheck(Actor akTarget) 
    if (akTarget as ObjectReference).GetAnimationVariablebool("bIsRiding") == false \
    && akTarget.IsSwimming() == false \
    && (akTarget as ObjectReference).GetAnimationVariablebool("bAnimationDriven") == false \
    && akTarget.IsInKillMove() == false \
    && (akTarget as ObjectReference).GetAnimationVariablebool("IsBleedingOut") == false\
    && (akTarget as ObjectReference).GetAnimationVariablebool("bIsSynced") == false
        Return true
    else
        Return false
    endif
EndFunction


; Sheathes the target's weapon and waits until the target has finished unequipping.
; Waits for a certain of maximum of seconds.
;
; Parameters:
; - TypeActor: The actor to sheathe their weapon.
; - TypeFloat: Maximun time in seconds that the function will wait.
;
; Return Value:
; - TypeBool: True if the target successfully sheathed their weapon on time; otherwise, false.
bool Function SheatheWeaponAndWait(Actor akTarget, float fMaxWaitTime)
    if akTarget.isWeaponDrawn() == true
        akTarget.SheatheWeapon()
        float fWaitTime = 0.0
        while (akTarget as ObjectReference).GetAnimationVariablebool("isUnEquipping") == true && fWaitTime < fMaxWaitTime
            Utility.wait(0.1)
            fWaitTime += 0.1
        endwhile

        if fWaitTime >= fMaxWaitTime
            return false
        endif
    endif
    return true
EndFunction
