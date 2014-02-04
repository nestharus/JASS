/****************************************************************************************
*                                                                                       *
*                               Ranged Bonus Power                                      *
*                                                                                       *
*   Power determines how big a bonus range can go. For example, a power of 15 would be  *
*   -(2^16) to 2^(16)-1 or -65536 to 65535.                                            *
*                                                                                       *
*****************************************************************************************
*                                                                                       *
*                               Unlimited Bonus Power                                   *
*                                                                                       *
*   Power for unlimited bonuses increases speed of add/remove for larger values         *
*   and makes larger values easier to get to. For example, 50,000,000 is much           *
*   faster adding units of 1,048,576 than adding units of 16. In units of 16,           *
*   50,000,000 might as well be impossible to get to.                                   *
*                                                                                       *
*****************************************************************************************
*                                                                                       *
*                               ENABLED                                                 *
*                                                                                       *
*   Should the bonus be implemented into the system? By disabling a bonus, it will not  *
*   be in the system at all. Abilities and constants won't be made.                     *
*                                                                                       *
****************************************************************************************/
//! textmacro BONUS_CREATE_BONUSES
    /********************
    *                   *
    *   ability data    *
    *                   *
    ********************/
    //                perc          abil        field       name                    ranged          enabled       max power
    //! i Ability.new(false,        "AId1",     "Idef",     "ARMOR",                true,           true,           12)         --> armor
    //! i Ability.new(false,        "AItg",     "Iatt",     "DAMAGE",               true,           true,           15)         --> damage
    //! i Ability.new(false,        "AIa1",     "Iagi",     "AGILITY",              true,           true,           13)         --> agility
    //! i Ability.new(false,        "AIs1",     "Istr",     "STRENGTH",             true,           true,           13)         --> strength
    //! i Ability.new(false,        "AIi1",     "Iint",     "INTELLIGENCE",         true,           true,           13)         --> intelligence
    //! i Ability.new(false,        "AIlf",     "Ilif",     "LIFE",                 false,          true,           17)         --> life
    //! i Ability.new(false,        "Arel",     "Ihpr",     "LIFE_REGEN",           true,           true,           15)         --> life regen
    //! i Ability.new(false,        "AImb",     "Iman",     "MANA",                 false,          true,           17)         --> mana
    //! i Ability.new(true,         "AIrm",     "Imrp",     "MANA_REGEN",           true,           true,           8)           --> mana regen, 8 max
    //! i Ability.new(false,        "AIsi",     "Isib",     "SIGHT",                true,           true,           10)         --> sight, 10 max
    //! i Ability.new(true,         "AIsx",     "Isx1",     "ATTACK_SPEED",         true,           true,           8)           --> attack speed, 8 max
//! endtextmacro

/********************
*                   *
*       code        *
*                   *
********************/
//! externalblock extension=lua ObjectMerger $FILENAME$
//! runtextmacro LUA_FILE_HEADER()
//! i dofile("GetVarObject")
//! i dofile("BonusAbility")
//! i dofile("BonusJASS")
//! runtextmacro BONUS_CREATE_BONUSES()
//! i local jass = BonusJASS.get(abilities)
//! i writejass("BONUS",jass)
//! i updateobjects()
//! endexternalblock