library AES /* v1.1.0.0
*************************************************************************************
*
*   128 bit
*
*************************************************************************************
*
*   */uses/*
*   
*       */ Matrix128 /*         hiveworkshop.com/forums/submissions-414/snippet-matrix128-226509/
*       */ sbox /*              hiveworkshop.com/forums/submissions-414/snippet-sbox-222638/    
*       */ ltable /*            hiveworkshop.com/forums/submissions-414/snippet-ltable-222643/
*       */ etable /*            hiveworkshop.com/forums/submissions-414/snippet-etable-222644/
*       */ sxor /*              hiveworkshop.com/forums/submissions-414/snippet-byte-xor-char-xor-222642/
*       */ bxor /*
*       */ sbyte /*             hiveworkshop.com/forums/submissions-414/snippet-ascii-byte-char-0xef-0xde-0xff-etc-222641/
*       */ bgmult /*            hiveworkshop.com/forums/submissions-414/snippet-bg-mult-222645/
*       */ rcon /*              hiveworkshop.com/forums/submissions-414/snippet-rcon-222658/
*       */ BitInt /*            hiveworkshop.com/forums/submissions-414/snippet-bitint-226174/
*
************************************************************************************
*
*   struct AES extends array
*
*       Description
*       -----------------------
*
*           encrypts/decrypts blocks of data using a cipher key
*
*       Creators/Destructors
*       -----------------------
*
*           static method create takes Matrix128 cipher returns AES
*           method destroy takes nothing returns nothing
*
*               -   An AES object can be reused, so there is no need to destroy it.
*
*               -   The cipher must already be initialized before it can be used to create
*               -   an AES object.
*
*       Fields
*       -----------------------
*
*           readonly Matrix128 cipher
*
*
*       Methods
*       -----------------------
*
*           method encrypt takes Matrix128 data returns nothing
*           method decrypt takes Matrix128 data returns nothing
*
*
************************************************************************************/
    private function B_XOR4 takes integer byte1, integer byte2, integer byte3, integer byte4 returns integer
        return B_XOR(B_XOR(B_XOR(byte1, byte2), byte3), byte4)
    endfunction
    
    private struct SubBytes extends array
        static method execute takes Matrix128 data returns nothing
            local integer last = data + 16
        
            loop
                set data.byte = sbox[data.byte]
                set data = data + 1
                exitwhen integer(data) == last
            endloop
        endmethod
    endstruct
    
    private struct InvSubBytes extends array
        static method execute takes Matrix128 data returns nothing
            local integer last = data + 16
        
            loop
                set data.byte = rsbox[data.byte]
                set data = data + 1
                exitwhen integer(data) == last
            endloop
        endmethod
    endstruct
    
    private struct ShiftRows extends array
        private static integer array s_rowd
        
        static method execute takes Matrix128 data returns nothing
            /*
            *   row 2
            */
            //! runtextmacro AES_LOAD_ROW()
            set Matrix128[data    ] = s_rowd[1]
            set Matrix128[data + 1] = s_rowd[2]
            set Matrix128[data + 2] = s_rowd[3]
            set Matrix128[data + 3] = s_rowd[0]
            
            /*
            *   row 3
            */
            //! runtextmacro AES_LOAD_ROW()
            set Matrix128[data    ] = s_rowd[2]
            set Matrix128[data + 1] = s_rowd[3]
            set Matrix128[data + 2] = s_rowd[0]
            set Matrix128[data + 3] = s_rowd[1]
            
            /*
            *   row 4
            */
            //! runtextmacro AES_LOAD_ROW()
            set Matrix128[data    ] = s_rowd[3]
            set Matrix128[data + 1] = s_rowd[0]
            set Matrix128[data + 2] = s_rowd[1]
            set Matrix128[data + 3] = s_rowd[2]
        endmethod
    endstruct
    private struct InvShiftRows extends array
        private static integer array s_rowd
        
        static method execute takes Matrix128 data returns nothing
            /*
            *   row 2
            */
            //! runtextmacro AES_LOAD_ROW()
            set Matrix128[data    ] = s_rowd[3]
            set Matrix128[data + 1] = s_rowd[0]
            set Matrix128[data + 2] = s_rowd[1]
            set Matrix128[data + 3] = s_rowd[2]
            
            /*
            *   row 3
            */
            //! runtextmacro AES_LOAD_ROW()
            set Matrix128[data    ] = s_rowd[2]
            set Matrix128[data + 1] = s_rowd[3]
            set Matrix128[data + 2] = s_rowd[0]
            set Matrix128[data + 3] = s_rowd[1]
            
            /*
            *   row 4
            */
            //! runtextmacro AES_LOAD_ROW()
            set Matrix128[data    ] = s_rowd[1]
            set Matrix128[data + 1] = s_rowd[2]
            set Matrix128[data + 2] = s_rowd[3]
            set Matrix128[data + 3] = s_rowd[0]
        endmethod
    endstruct
    //! textmacro AES_LOAD_ROW
        set data = data + 4
        set s_rowd[0] = Matrix128[data    ]
        set s_rowd[1] = Matrix128[data + 1]
        set s_rowd[2] = Matrix128[data + 2]
        set s_rowd[3] = Matrix128[data + 3]
    //! endtextmacro
    
    private struct MixColumns extends array
        private static integer array row
        
        static method execute takes Matrix128 data returns nothing
            /*
                ----   --         --
                |d0|   |02 03 01 01|    02.d0 XOR 03.d1 XOR 01.d2 XOR 01.d3
                |d1| x |01 02 03 01| -> 01.d0 XOR 02.d1 XOR 03.d2 XOR 01.d3
                |d2|   |01 01 02 03|    01.d0 XOR 01.d1 XOR 02.d2 XOR 03.d3
                |d3|   |03 01 01 02|    03.d0 XOR 01.d1 XOR 01.d2 XOR 02.d3
                ----   --         --
            */
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x02, row[0]), BG_MULT(0x03, row[1]), /*BGM*/(/*1*/ row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  4] = B_XOR4(/*BGM*/(/*1*/ row[0]), BG_MULT(0x02, row[1]), BG_MULT(0x03, row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  8] = B_XOR4(/*BGM*/(/*1*/ row[0]), /*BGM*/(/*1*/ row[1]), BG_MULT(0x02, row[2]), BG_MULT(0x03, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x03, row[0]), /*BGM*/(/*1*/ row[1]), /*BGM*/(/*1*/ row[2]), BG_MULT(0x02, row[3]))
            
            set data = data + 1
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x02, row[0]), BG_MULT(0x03, row[1]), /*BGM*/(/*1*/ row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  4] = B_XOR4(/*BGM*/(/*1*/ row[0]), BG_MULT(0x02, row[1]), BG_MULT(0x03, row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  8] = B_XOR4(/*BGM*/(/*1*/ row[0]), /*BGM*/(/*1*/ row[1]), BG_MULT(0x02, row[2]), BG_MULT(0x03, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x03, row[0]), /*BGM*/(/*1*/ row[1]), /*BGM*/(/*1*/ row[2]), BG_MULT(0x02, row[3]))
            
            set data = data + 1
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x02, row[0]), BG_MULT(0x03, row[1]), /*BGM*/(/*1*/ row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  4] = B_XOR4(/*BGM*/(/*1*/ row[0]), BG_MULT(0x02, row[1]), BG_MULT(0x03, row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  8] = B_XOR4(/*BGM*/(/*1*/ row[0]), /*BGM*/(/*1*/ row[1]), BG_MULT(0x02, row[2]), BG_MULT(0x03, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x03, row[0]), /*BGM*/(/*1*/ row[1]), /*BGM*/(/*1*/ row[2]), BG_MULT(0x02, row[3]))
            
            set data = data + 1
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x02, row[0]), BG_MULT(0x03, row[1]), /*BGM*/(/*1*/ row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  4] = B_XOR4(/*BGM*/(/*1*/ row[0]), BG_MULT(0x02, row[1]), BG_MULT(0x03, row[2]), /*BGM*/(/*1*/ row[3]))
            set Matrix128[data +  8] = B_XOR4(/*BGM*/(/*1*/ row[0]), /*BGM*/(/*1*/ row[1]), BG_MULT(0x02, row[2]), BG_MULT(0x03, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x03, row[0]), /*BGM*/(/*1*/ row[1]), /*BGM*/(/*1*/ row[2]), BG_MULT(0x02, row[3]))
        endmethod
    endstruct
    private struct InvMixColumns extends array
        private static integer array row
        
        static method execute takes Matrix128 data returns nothing
            /*
                ----   --         --
                |d0|   |0e 0b 0d 09|    0e.d0 XOR 0b.d1 XOR 0d.d2 XOR 09.d3
                |d1| x |09 0e 0b 0d| -> 09.d0 XOR 0e.d1 XOR 0b.d2 XOR 0d.d3
                |d2|   |0d 09 0e 0b|    0d.d0 XOR 09.d1 XOR 0e.d2 XOR 0b.d3
                |d3|   |0b 0d 09 0e|    0b.d0 XOR 0d.d1 XOR 09.d2 XOR 0e.d3
                ----   --         --
            */
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x0e, row[0]), BG_MULT(0x0b, row[1]), BG_MULT(0x0d, row[2]), BG_MULT(0x09, row[3]))
            set Matrix128[data +  4] = B_XOR4(BG_MULT(0x09, row[0]), BG_MULT(0x0e, row[1]), BG_MULT(0x0b, row[2]), BG_MULT(0x0d, row[3]))
            set Matrix128[data +  8] = B_XOR4(BG_MULT(0x0d, row[0]), BG_MULT(0x09, row[1]), BG_MULT(0x0e, row[2]), BG_MULT(0x0b, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x0b, row[0]), BG_MULT(0x0d, row[1]), BG_MULT(0x09, row[2]), BG_MULT(0x0e, row[3]))
            
            set data = data + 1
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x0e, row[0]), BG_MULT(0x0b, row[1]), BG_MULT(0x0d, row[2]), BG_MULT(0x09, row[3]))
            set Matrix128[data +  4] = B_XOR4(BG_MULT(0x09, row[0]), BG_MULT(0x0e, row[1]), BG_MULT(0x0b, row[2]), BG_MULT(0x0d, row[3]))
            set Matrix128[data +  8] = B_XOR4(BG_MULT(0x0d, row[0]), BG_MULT(0x09, row[1]), BG_MULT(0x0e, row[2]), BG_MULT(0x0b, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x0b, row[0]), BG_MULT(0x0d, row[1]), BG_MULT(0x09, row[2]), BG_MULT(0x0e, row[3]))
            
            set data = data + 1
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x0e, row[0]), BG_MULT(0x0b, row[1]), BG_MULT(0x0d, row[2]), BG_MULT(0x09, row[3]))
            set Matrix128[data +  4] = B_XOR4(BG_MULT(0x09, row[0]), BG_MULT(0x0e, row[1]), BG_MULT(0x0b, row[2]), BG_MULT(0x0d, row[3]))
            set Matrix128[data +  8] = B_XOR4(BG_MULT(0x0d, row[0]), BG_MULT(0x09, row[1]), BG_MULT(0x0e, row[2]), BG_MULT(0x0b, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x0b, row[0]), BG_MULT(0x0d, row[1]), BG_MULT(0x09, row[2]), BG_MULT(0x0e, row[3]))
            
            set data = data + 1
            //! runtextmacro LOAD_COL()
            set Matrix128[data     ] = B_XOR4(BG_MULT(0x0e, row[0]), BG_MULT(0x0b, row[1]), BG_MULT(0x0d, row[2]), BG_MULT(0x09, row[3]))
            set Matrix128[data +  4] = B_XOR4(BG_MULT(0x09, row[0]), BG_MULT(0x0e, row[1]), BG_MULT(0x0b, row[2]), BG_MULT(0x0d, row[3]))
            set Matrix128[data +  8] = B_XOR4(BG_MULT(0x0d, row[0]), BG_MULT(0x09, row[1]), BG_MULT(0x0e, row[2]), BG_MULT(0x0b, row[3]))
            set Matrix128[data + 12] = B_XOR4(BG_MULT(0x0b, row[0]), BG_MULT(0x0d, row[1]), BG_MULT(0x09, row[2]), BG_MULT(0x0e, row[3]))
        endmethod
    endstruct
    //! textmacro LOAD_COL
        set row[0] = Matrix128[data     ]
        set row[1] = Matrix128[data +  4]
        set row[2] = Matrix128[data +  8]
        set row[3] = Matrix128[data + 12]
    //! endtextmacro
    
    private struct AddRoundKey extends array
        static method execute takes Matrix128 data, Matrix128 cipher returns nothing
            set Matrix128[data      ] = B_XOR(Matrix128[data      ], Matrix128[cipher      ])
            set Matrix128[data + 0x1] = B_XOR(Matrix128[data + 0x1], Matrix128[cipher + 0x1])
            set Matrix128[data + 0x2] = B_XOR(Matrix128[data + 0x2], Matrix128[cipher + 0x2])
            set Matrix128[data + 0x3] = B_XOR(Matrix128[data + 0x3], Matrix128[cipher + 0x3])
            set Matrix128[data + 0x4] = B_XOR(Matrix128[data + 0x4], Matrix128[cipher + 0x4])
            set Matrix128[data + 0x5] = B_XOR(Matrix128[data + 0x5], Matrix128[cipher + 0x5])
            set Matrix128[data + 0x6] = B_XOR(Matrix128[data + 0x6], Matrix128[cipher + 0x6])
            set Matrix128[data + 0x7] = B_XOR(Matrix128[data + 0x7], Matrix128[cipher + 0x7])
            set Matrix128[data + 0x8] = B_XOR(Matrix128[data + 0x8], Matrix128[cipher + 0x8])
            set Matrix128[data + 0x9] = B_XOR(Matrix128[data + 0x9], Matrix128[cipher + 0x9])
            set Matrix128[data + 0xa] = B_XOR(Matrix128[data + 0xa], Matrix128[cipher + 0xa])
            set Matrix128[data + 0xb] = B_XOR(Matrix128[data + 0xb], Matrix128[cipher + 0xb])
            set Matrix128[data + 0xc] = B_XOR(Matrix128[data + 0xc], Matrix128[cipher + 0xc])
            set Matrix128[data + 0xd] = B_XOR(Matrix128[data + 0xd], Matrix128[cipher + 0xd])
            set Matrix128[data + 0xe] = B_XOR(Matrix128[data + 0xe], Matrix128[cipher + 0xe])
            set Matrix128[data + 0xf] = B_XOR(Matrix128[data + 0xf], Matrix128[cipher + 0xf])
        endmethod
    endstruct
    
    private struct KeySchedule extends array
        private static method B_XOR3 takes integer byte1, integer byte2, integer byte3 returns integer
            return B_XOR(B_XOR(byte1, byte2), byte3)
        endmethod
    
        static method execute takes Matrix128 cipher, integer round, Matrix128 cipherstore returns Matrix128
            set Matrix128[cipherstore     ] = B_XOR3(Matrix128[cipher     ], sbox[Matrix128[cipher +  7]], rcon[round])
            set Matrix128[cipherstore +  4] = B_XOR (Matrix128[cipher +  4], sbox[Matrix128[cipher + 11]])
            set Matrix128[cipherstore +  8] = B_XOR (Matrix128[cipher +  8], sbox[Matrix128[cipher + 15]])
            set Matrix128[cipherstore + 12] = B_XOR (Matrix128[cipher + 12], sbox[Matrix128[cipher +  3]])
            
            set Matrix128[cipherstore +  1] = B_XOR (Matrix128[cipher +  1], Matrix128[cipherstore     ])
            set Matrix128[cipherstore +  5] = B_XOR (Matrix128[cipher +  5], Matrix128[cipherstore +  4])
            set Matrix128[cipherstore +  9] = B_XOR (Matrix128[cipher +  9], Matrix128[cipherstore +  8])
            set Matrix128[cipherstore + 13] = B_XOR (Matrix128[cipher + 13], Matrix128[cipherstore + 12])
            
            set Matrix128[cipherstore +  2] = B_XOR (Matrix128[cipher +  2], Matrix128[cipherstore +  1])
            set Matrix128[cipherstore +  6] = B_XOR (Matrix128[cipher +  6], Matrix128[cipherstore +  5])
            set Matrix128[cipherstore + 10] = B_XOR (Matrix128[cipher + 10], Matrix128[cipherstore +  9])
            set Matrix128[cipherstore + 14] = B_XOR (Matrix128[cipher + 14], Matrix128[cipherstore + 13])
            
            set Matrix128[cipherstore +  3] = B_XOR (Matrix128[cipher +  3], Matrix128[cipherstore +  2])
            set Matrix128[cipherstore +  7] = B_XOR (Matrix128[cipher +  7], Matrix128[cipherstore +  6])
            set Matrix128[cipherstore + 11] = B_XOR (Matrix128[cipher + 11], Matrix128[cipherstore + 10])
            set Matrix128[cipherstore + 15] = B_XOR (Matrix128[cipher + 15], Matrix128[cipherstore + 14])
            
            return cipherstore
        endmethod
    endstruct
    
    struct AES extends array
        private static integer instanceCount = 1
        private static integer array recycler
        
        readonly Matrix128 cipher
        
        private static method operator [] takes thistype this returns Matrix128
            return cipher
        endmethod
        private static method operator []= takes thistype this, integer value returns nothing
            set cipher = value
        endmethod
    
        static method create takes Matrix128 cipher returns thistype
            local thistype this = recycler[0]
            
            if (0 == this) then
                debug if (instanceCount + 16 > 8191) then
                    debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"AES Overflow")
                    debug set this = 1/0
                debug endif
            
                set this = instanceCount
                set instanceCount = this + 11
            else
                set recycler[0] = recycler[this]
            endif
            
            debug set recycler[this] = -1
            
            set this.cipher = cipher
            
            set thistype[this + 0x1] = KeySchedule.execute(thistype[this      ], 0x1, Matrix128.create())
            set thistype[this + 0x2] = KeySchedule.execute(thistype[this + 0x1], 0x2, Matrix128.create())
            set thistype[this + 0x3] = KeySchedule.execute(thistype[this + 0x2], 0x3, Matrix128.create())
            set thistype[this + 0x4] = KeySchedule.execute(thistype[this + 0x3], 0x4, Matrix128.create())
            set thistype[this + 0x5] = KeySchedule.execute(thistype[this + 0x4], 0x5, Matrix128.create())
            set thistype[this + 0x6] = KeySchedule.execute(thistype[this + 0x5], 0x6, Matrix128.create())
            set thistype[this + 0x7] = KeySchedule.execute(thistype[this + 0x6], 0x7, Matrix128.create())
            set thistype[this + 0x8] = KeySchedule.execute(thistype[this + 0x7], 0x8, Matrix128.create())
            set thistype[this + 0x9] = KeySchedule.execute(thistype[this + 0x8], 0x9, Matrix128.create())
            set thistype[this + 0xa] = KeySchedule.execute(thistype[this + 0x9], 0xa, Matrix128.create())
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            debug if (recycler[this] != -1) then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"AES Double Free Error: " + I2S(this))
                debug set this = 1/0
            debug endif
        
            set recycler[this] = recycler[0]
            set recycler[0] = this
            
            call thistype[this + 0x1].destroy()
            call thistype[this + 0x2].destroy()
            call thistype[this + 0x3].destroy()
            call thistype[this + 0x4].destroy()
            call thistype[this + 0x5].destroy()
            call thistype[this + 0x6].destroy()
            call thistype[this + 0x7].destroy()
            call thistype[this + 0x8].destroy()
            call thistype[this + 0x9].destroy()
            call thistype[this + 0xa].destroy()
        endmethod
        
        method encrypt takes Matrix128 data returns nothing
            local integer round = 0
            
            /*
            *   round 0
            */
            call AddRoundKey.execute(data, cipher)
            
            /*
            *   round 1 - 9
            */
            loop
                set round = round + 1
                
                call SubBytes.execute(data)
                call ShiftRows.execute(data)
                call MixColumns.execute(data)
                
                call AddRoundKey.execute(data, thistype[this + round])
                
                exitwhen round == 9
            endloop
            
            /*
            *   round 10
            */
            set round = round + 1
            call SubBytes.execute(data)
            call ShiftRows.execute(data)
            
            call AddRoundKey.execute(data, thistype[this + round])
        endmethod
        
        method decrypt takes Matrix128 data returns nothing
            local integer round = 10
            
            call AddRoundKey.execute(data, thistype[this + round])
            call InvShiftRows.execute(data)
            call InvSubBytes.execute(data)
            
            loop
                set round = round - 1
                
                call AddRoundKey.execute(data, thistype[this + round])
                call InvMixColumns.execute(data)
                call InvShiftRows.execute(data)
                call InvSubBytes.execute(data)
                
                exitwhen 1 == round
            endloop
            
            call AddRoundKey.execute(data, cipher)
        endmethod
    endstruct
endlibrary