library rcon
    /*
        readonly integer array rcon
        
        credits to wikipedia
            en.wikipedia.org/wiki/Rijndael_key_schedule#Rcon
        
           | 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
        -- | --|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|
        00 | 8d 01 02 04 08 10 20 40 80 1b 36 6c d8 ab 4d 9a 
        10 | 2f 5e bc 63 c6 97 35 6a d4 b3 7d fa ef c5 91 39 
        20 | 72 e4 d3 bd 61 c2 9f 25 4a 94 33 66 cc 83 1d 3a 
        30 | 74 e8 cb 8d 01 02 04 08 10 20 40 80 1b 36 6c d8 
        40 | ab 4d 9a 2f 5e bc 63 c6 97 35 6a d4 b3 7d fa ef 
        50 | c5 91 39 72 e4 d3 bd 61 c2 9f 25 4a 94 33 66 cc 
        60 | 83 1d 3a 74 e8 cb 8d 01 02 04 08 10 20 40 80 1b 
        70 | 36 6c d8 ab 4d 9a 2f 5e bc 63 c6 97 35 6a d4 b3 
        80 | 7d fa ef c5 91 39 72 e4 d3 bd 61 c2 9f 25 4a 94 
        90 | 33 66 cc 83 1d 3a 74 e8 cb 8d 01 02 04 08 10 20 
        a0 | 40 80 1b 36 6c d8 ab 4d 9a 2f 5e bc 63 c6 97 35 
        b0 | 6a d4 b3 7d fa ef c5 91 39 72 e4 d3 bd 61 c2 9f 
        c0 | 25 4a 94 33 66 cc 83 1d 3a 74 e8 cb 8d 01 02 04 
        d0 | 08 10 20 40 80 1b 36 6c d8 ab 4d 9a 2f 5e bc 63 
        e0 | c6 97 35 6a d4 b3 7d fa ef c5 91 39 72 e4 d3 bd
        f0 | 61 c2 9f 25 4a 94 33 66 cc 83 1d 3a 74 e8 cb 8d
    */
    
    private module rconm
        private static method onInit takes nothing returns nothing
            set data[0x0] = 0x8d
            set data[0x1] = 0x1
            set data[0x2] = 0x2
            set data[0x3] = 0x4
            set data[0x4] = 0x8
            set data[0x5] = 0x10
            set data[0x6] = 0x20
            set data[0x7] = 0x40
            set data[0x8] = 0x80
            set data[0x9] = 0x1b
            set data[0xa] = 0x36
            set data[0xb] = 0x6c
            set data[0xc] = 0xd8
            set data[0xd] = 0xab
            set data[0xe] = 0x4d
            set data[0xf] = 0x9a
            set data[0x10] = 0x2f
            set data[0x11] = 0x5e
            set data[0x12] = 0xbc
            set data[0x13] = 0x63
            set data[0x14] = 0xc6
            set data[0x15] = 0x97
            set data[0x16] = 0x35
            set data[0x17] = 0x6a
            set data[0x18] = 0xd4
            set data[0x19] = 0xb3
            set data[0x1a] = 0x7d
            set data[0x1b] = 0xfa
            set data[0x1c] = 0xef
            set data[0x1d] = 0xc5
            set data[0x1e] = 0x91
            set data[0x1f] = 0x39
            set data[0x20] = 0x72
            set data[0x21] = 0xe4
            set data[0x22] = 0xd3
            set data[0x23] = 0xbd
            set data[0x24] = 0x61
            set data[0x25] = 0xc2
            set data[0x26] = 0x9f
            set data[0x27] = 0x25
            set data[0x28] = 0x4a
            set data[0x29] = 0x94
            set data[0x2a] = 0x33
            set data[0x2b] = 0x66
            set data[0x2c] = 0xcc
            set data[0x2d] = 0x83
            set data[0x2e] = 0x1d
            set data[0x2f] = 0x3a
            set data[0x30] = 0x74
            set data[0x31] = 0xe8
            set data[0x32] = 0xcb
            set data[0x33] = 0x8d
            set data[0x34] = 0x1
            set data[0x35] = 0x2
            set data[0x36] = 0x4
            set data[0x37] = 0x8
            set data[0x38] = 0x10
            set data[0x39] = 0x20
            set data[0x3a] = 0x40
            set data[0x3b] = 0x80
            set data[0x3c] = 0x1b
            set data[0x3d] = 0x36
            set data[0x3e] = 0x6c
            set data[0x3f] = 0xd8
            set data[0x40] = 0xab
            set data[0x41] = 0x4d
            set data[0x42] = 0x9a
            set data[0x43] = 0x2f
            set data[0x44] = 0x5e
            set data[0x45] = 0xbc
            set data[0x46] = 0x63
            set data[0x47] = 0xc6
            set data[0x48] = 0x97
            set data[0x49] = 0x35
            set data[0x4a] = 0x6a
            set data[0x4b] = 0xd4
            set data[0x4c] = 0xb3
            set data[0x4d] = 0x7d
            set data[0x4e] = 0xfa
            set data[0x4f] = 0xef
            set data[0x50] = 0xc5
            set data[0x51] = 0x91
            set data[0x52] = 0x39
            set data[0x53] = 0x72
            set data[0x54] = 0xe4
            set data[0x55] = 0xd3
            set data[0x56] = 0xbd
            set data[0x57] = 0x61
            set data[0x58] = 0xc2
            set data[0x59] = 0x9f
            set data[0x5a] = 0x25
            set data[0x5b] = 0x4a
            set data[0x5c] = 0x94
            set data[0x5d] = 0x33
            set data[0x5e] = 0x66
            set data[0x5f] = 0xcc
            set data[0x60] = 0x83
            set data[0x61] = 0x1d
            set data[0x62] = 0x3a
            set data[0x63] = 0x74
            set data[0x64] = 0xe8
            set data[0x65] = 0xcb
            set data[0x66] = 0x8d
            set data[0x67] = 0x1
            set data[0x68] = 0x2
            set data[0x69] = 0x4
            set data[0x6a] = 0x8
            set data[0x6b] = 0x10
            set data[0x6c] = 0x20
            set data[0x6d] = 0x40
            set data[0x6e] = 0x80
            set data[0x6f] = 0x1b
            set data[0x70] = 0x36
            set data[0x71] = 0x6c
            set data[0x72] = 0xd8
            set data[0x73] = 0xab
            set data[0x74] = 0x4d
            set data[0x75] = 0x9a
            set data[0x76] = 0x2f
            set data[0x77] = 0x5e
            set data[0x78] = 0xbc
            set data[0x79] = 0x63
            set data[0x7a] = 0xc6
            set data[0x7b] = 0x97
            set data[0x7c] = 0x35
            set data[0x7d] = 0x6a
            set data[0x7e] = 0xd4
            set data[0x7f] = 0xb3
            set data[0x80] = 0x7d
            set data[0x81] = 0xfa
            set data[0x82] = 0xef
            set data[0x83] = 0xc5
            set data[0x84] = 0x91
            set data[0x85] = 0x39
            set data[0x86] = 0x72
            set data[0x87] = 0xe4
            set data[0x88] = 0xd3
            set data[0x89] = 0xbd
            set data[0x8a] = 0x61
            set data[0x8b] = 0xc2
            set data[0x8c] = 0x9f
            set data[0x8d] = 0x25
            set data[0x8e] = 0x4a
            set data[0x8f] = 0x94
            set data[0x90] = 0x33
            set data[0x91] = 0x66
            set data[0x92] = 0xcc
            set data[0x93] = 0x83
            set data[0x94] = 0x1d
            set data[0x95] = 0x3a
            set data[0x96] = 0x74
            set data[0x97] = 0xe8
            set data[0x98] = 0xcb
            set data[0x99] = 0x8d
            set data[0x9a] = 0x1
            set data[0x9b] = 0x2
            set data[0x9c] = 0x4
            set data[0x9d] = 0x8
            set data[0x9e] = 0x10
            set data[0x9f] = 0x20
            set data[0xa0] = 0x40
            set data[0xa1] = 0x80
            set data[0xa2] = 0x1b
            set data[0xa3] = 0x36
            set data[0xa4] = 0x6c
            set data[0xa5] = 0xd8
            set data[0xa6] = 0xab
            set data[0xa7] = 0x4d
            set data[0xa8] = 0x9a
            set data[0xa9] = 0x2f
            set data[0xaa] = 0x5e
            set data[0xab] = 0xbc
            set data[0xac] = 0x63
            set data[0xad] = 0xc6
            set data[0xae] = 0x97
            set data[0xaf] = 0x35
            set data[0xb0] = 0x6a
            set data[0xb1] = 0xd4
            set data[0xb2] = 0xb3
            set data[0xb3] = 0x7d
            set data[0xb4] = 0xfa
            set data[0xb5] = 0xef
            set data[0xb6] = 0xc5
            set data[0xb7] = 0x91
            set data[0xb8] = 0x39
            set data[0xb9] = 0x72
            set data[0xba] = 0xe4
            set data[0xbb] = 0xd3
            set data[0xbc] = 0xbd
            set data[0xbd] = 0x61
            set data[0xbe] = 0xc2
            set data[0xbf] = 0x9f
            set data[0xc0] = 0x25
            set data[0xc1] = 0x4a
            set data[0xc2] = 0x94
            set data[0xc3] = 0x33
            set data[0xc4] = 0x66
            set data[0xc5] = 0xcc
            set data[0xc6] = 0x83
            set data[0xc7] = 0x1d
            set data[0xc8] = 0x3a
            set data[0xc9] = 0x74
            set data[0xca] = 0xe8
            set data[0xcb] = 0xcb
            set data[0xcc] = 0x8d
            set data[0xcd] = 0x1
            set data[0xce] = 0x2
            set data[0xcf] = 0x4
            set data[0xd0] = 0x8
            set data[0xd1] = 0x10
            set data[0xd2] = 0x20
            set data[0xd3] = 0x40
            set data[0xd4] = 0x80
            set data[0xd5] = 0x1b
            set data[0xd6] = 0x36
            set data[0xd7] = 0x6c
            set data[0xd8] = 0xd8
            set data[0xd9] = 0xab
            set data[0xda] = 0x4d
            set data[0xdb] = 0x9a
            set data[0xdc] = 0x2f
            set data[0xdd] = 0x5e
            set data[0xde] = 0xbc
            set data[0xdf] = 0x63
            set data[0xe0] = 0xc6
            set data[0xe1] = 0x97
            set data[0xe2] = 0x35
            set data[0xe3] = 0x6a
            set data[0xe4] = 0xd4
            set data[0xe5] = 0xb3
            set data[0xe6] = 0x7d
            set data[0xe7] = 0xfa
            set data[0xe8] = 0xef
            set data[0xe9] = 0xc5
            set data[0xea] = 0x91
            set data[0xeb] = 0x39
            set data[0xec] = 0x72
            set data[0xed] = 0xe4
            set data[0xee] = 0xd3
            set data[0xef] = 0xbd
            set data[0xf0] = 0x61
            set data[0xf1] = 0xc2
            set data[0xf2] = 0x9f
            set data[0xf3] = 0x25
            set data[0xf4] = 0x4a
            set data[0xf5] = 0x94
            set data[0xf6] = 0x33
            set data[0xf7] = 0x66
            set data[0xf8] = 0xcc
            set data[0xf9] = 0x83
            set data[0xfa] = 0x1d
            set data[0xfb] = 0x3a
            set data[0xfc] = 0x74
            set data[0xfd] = 0xe8
            set data[0xfe] = 0xcb
            set data[0xff] = 0x8d
        endmethod
    endmodule
    
    struct rcon extends array
        private static integer array data
        
        static method operator [] takes integer i returns integer
            return data[i]
        endmethod
        
        implement rconm
    endstruct
endlibrary