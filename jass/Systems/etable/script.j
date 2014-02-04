library etable
    /*
        readonly integer array etable
    
            02.d4 = ltable[02] + ltable[d4]
            if (result > ff) result = result - ff
            result = etable[result]
        
            samiam.org/galois.html
            
            table provided by intel
            
           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0 01 03 05 0F 11 33 55 FF 1A 2E 72 96 A1 F8 13 35
        1 5F E1 38 48 D8 73 95 A4 F7 02 06 0A 1E 22 66 AA
        2 E5 34 5C E4 37 59 EB 26 6A BE D9 70 90 AB E6 31
        3 53 F5 04 0C 14 3C 44 CC 4F D1 68 B8 D3 6E B2 CD
        4 4C D4 67 A9 E0 3B 4D D7 62 A6 F1 08 18 28 78 88
        5 83 9E B9 D0 6B BD DC 7F 81 98 B3 CE 49 DB 76 9A
        6 B5 C4 57 F9 10 30 50 F0 0B 1D 27 69 BB D6 61 A3
        7 FE 19 2B 7D 87 92 AD EC 2F 71 93 AE E9 20 60 A0
        8 FB 16 3A 4E D2 6D B7 C2 5D E7 32 56 FA 15 3F 41
        9 C3 5E E2 3D 47 C9 40 C0 5B ED 2C 74 9C BF DA 75
        A 9F BA D5 64 AC EF 2A 7E 82 9D BC DF 7A 8E 89 80
        B 9B B6 C1 58 E8 23 65 AF EA 25 6F B1 C8 43 C5 54
        C FC 1F 21 63 A5 F4 07 09 1B 2D 77 99 B0 CB 46 CA
        D 45 CF 4A DE 79 8B 86 91 A8 E3 3E 42 C6 51 F3 0E
        E 12 36 5A EE 29 7B 8D 8C 8F 8A 85 94 A7 F2 0D 17
        F 39 4B DD 7C 84 97 A2 FD 1C 24 6C B4 C7 52 F6 01
    */
    
    private module etablem
        private static integer array data
        
        static constant method operator [] takes integer val returns integer
            return data[val]
        endmethod
        
        private static method onInit takes nothing returns nothing
            set data[0x0] = 0x1
            set data[0x1] = 0x3
            set data[0x2] = 0x5
            set data[0x3] = 0xf
            set data[0x4] = 0x11
            set data[0x5] = 0x33
            set data[0x6] = 0x55
            set data[0x7] = 0xff
            set data[0x8] = 0x1a
            set data[0x9] = 0x2e
            set data[0xa] = 0x72
            set data[0xb] = 0x96
            set data[0xc] = 0xa1
            set data[0xd] = 0xf8
            set data[0xe] = 0x13
            set data[0xf] = 0x35
            set data[0x10] = 0x5f
            set data[0x11] = 0xe1
            set data[0x12] = 0x38
            set data[0x13] = 0x48
            set data[0x14] = 0xd8
            set data[0x15] = 0x73
            set data[0x16] = 0x95
            set data[0x17] = 0xa4
            set data[0x18] = 0xf7
            set data[0x19] = 0x2
            set data[0x1a] = 0x6
            set data[0x1b] = 0xa
            set data[0x1c] = 0x1e
            set data[0x1d] = 0x22
            set data[0x1e] = 0x66
            set data[0x1f] = 0xaa
            set data[0x20] = 0xe5
            set data[0x21] = 0x34
            set data[0x22] = 0x5c
            set data[0x23] = 0xe4
            set data[0x24] = 0x37
            set data[0x25] = 0x59
            set data[0x26] = 0xeb
            set data[0x27] = 0x26
            set data[0x28] = 0x6a
            set data[0x29] = 0xbe
            set data[0x2a] = 0xd9
            set data[0x2b] = 0x70
            set data[0x2c] = 0x90
            set data[0x2d] = 0xab
            set data[0x2e] = 0xe6
            set data[0x2f] = 0x31
            set data[0x30] = 0x53
            set data[0x31] = 0xf5
            set data[0x32] = 0x4
            set data[0x33] = 0xc
            set data[0x34] = 0x14
            set data[0x35] = 0x3c
            set data[0x36] = 0x44
            set data[0x37] = 0xcc
            set data[0x38] = 0x4f
            set data[0x39] = 0xd1
            set data[0x3a] = 0x68
            set data[0x3b] = 0xb8
            set data[0x3c] = 0xd3
            set data[0x3d] = 0x6e
            set data[0x3e] = 0xb2
            set data[0x3f] = 0xcd
            set data[0x40] = 0x4c
            set data[0x41] = 0xd4
            set data[0x42] = 0x67
            set data[0x43] = 0xa9
            set data[0x44] = 0xe0
            set data[0x45] = 0x3b
            set data[0x46] = 0x4d
            set data[0x47] = 0xd7
            set data[0x48] = 0x62
            set data[0x49] = 0xa6
            set data[0x4a] = 0xf1
            set data[0x4b] = 0x8
            set data[0x4c] = 0x18
            set data[0x4d] = 0x28
            set data[0x4e] = 0x78
            set data[0x4f] = 0x88
            set data[0x50] = 0x83
            set data[0x51] = 0x9e
            set data[0x52] = 0xb9
            set data[0x53] = 0xd0
            set data[0x54] = 0x6b
            set data[0x55] = 0xbd
            set data[0x56] = 0xdc
            set data[0x57] = 0x7f
            set data[0x58] = 0x81
            set data[0x59] = 0x98
            set data[0x5a] = 0xb3
            set data[0x5b] = 0xce
            set data[0x5c] = 0x49
            set data[0x5d] = 0xdb
            set data[0x5e] = 0x76
            set data[0x5f] = 0x9a
            set data[0x60] = 0xb5
            set data[0x61] = 0xc4
            set data[0x62] = 0x57
            set data[0x63] = 0xf9
            set data[0x64] = 0x10
            set data[0x65] = 0x30
            set data[0x66] = 0x50
            set data[0x67] = 0xf0
            set data[0x68] = 0xb
            set data[0x69] = 0x1d
            set data[0x6a] = 0x27
            set data[0x6b] = 0x69
            set data[0x6c] = 0xbb
            set data[0x6d] = 0xd6
            set data[0x6e] = 0x61
            set data[0x6f] = 0xa3
            set data[0x70] = 0xfe
            set data[0x71] = 0x19
            set data[0x72] = 0x2b
            set data[0x73] = 0x7d
            set data[0x74] = 0x87
            set data[0x75] = 0x92
            set data[0x76] = 0xad
            set data[0x77] = 0xec
            set data[0x78] = 0x2f
            set data[0x79] = 0x71
            set data[0x7a] = 0x93
            set data[0x7b] = 0xae
            set data[0x7c] = 0xe9
            set data[0x7d] = 0x20
            set data[0x7e] = 0x60
            set data[0x7f] = 0xa0
            set data[0x80] = 0xfb
            set data[0x81] = 0x16
            set data[0x82] = 0x3a
            set data[0x83] = 0x4e
            set data[0x84] = 0xd2
            set data[0x85] = 0x6d
            set data[0x86] = 0xb7
            set data[0x87] = 0xc2
            set data[0x88] = 0x5d
            set data[0x89] = 0xe7
            set data[0x8a] = 0x32
            set data[0x8b] = 0x56
            set data[0x8c] = 0xfa
            set data[0x8d] = 0x15
            set data[0x8e] = 0x3f
            set data[0x8f] = 0x41
            set data[0x90] = 0xc3
            set data[0x91] = 0x5e
            set data[0x92] = 0xe2
            set data[0x93] = 0x3d
            set data[0x94] = 0x47
            set data[0x95] = 0xc9
            set data[0x96] = 0x40
            set data[0x97] = 0xc0
            set data[0x98] = 0x5b
            set data[0x99] = 0xed
            set data[0x9a] = 0x2c
            set data[0x9b] = 0x74
            set data[0x9c] = 0x9c
            set data[0x9d] = 0xbf
            set data[0x9e] = 0xda
            set data[0x9f] = 0x75
            set data[0xa0] = 0x9f
            set data[0xa1] = 0xba
            set data[0xa2] = 0xd5
            set data[0xa3] = 0x64
            set data[0xa4] = 0xac
            set data[0xa5] = 0xef
            set data[0xa6] = 0x2a
            set data[0xa7] = 0x7e
            set data[0xa8] = 0x82
            set data[0xa9] = 0x9d
            set data[0xaa] = 0xbc
            set data[0xab] = 0xdf
            set data[0xac] = 0x7a
            set data[0xad] = 0x8e
            set data[0xae] = 0x89
            set data[0xaf] = 0x80
            set data[0xb0] = 0x9b
            set data[0xb1] = 0xb6
            set data[0xb2] = 0xc1
            set data[0xb3] = 0x58
            set data[0xb4] = 0xe8
            set data[0xb5] = 0x23
            set data[0xb6] = 0x65
            set data[0xb7] = 0xaf
            set data[0xb8] = 0xea
            set data[0xb9] = 0x25
            set data[0xba] = 0x6f
            set data[0xbb] = 0xb1
            set data[0xbc] = 0xc8
            set data[0xbd] = 0x43
            set data[0xbe] = 0xc5
            set data[0xbf] = 0x54
            set data[0xc0] = 0xfc
            set data[0xc1] = 0x1f
            set data[0xc2] = 0x21
            set data[0xc3] = 0x63
            set data[0xc4] = 0xa5
            set data[0xc5] = 0xf4
            set data[0xc6] = 0x7
            set data[0xc7] = 0x9
            set data[0xc8] = 0x1b
            set data[0xc9] = 0x2d
            set data[0xca] = 0x77
            set data[0xcb] = 0x99
            set data[0xcc] = 0xb0
            set data[0xcd] = 0xcb
            set data[0xce] = 0x46
            set data[0xcf] = 0xca
            set data[0xd0] = 0x45
            set data[0xd1] = 0xcf
            set data[0xd2] = 0x4a
            set data[0xd3] = 0xde
            set data[0xd4] = 0x79
            set data[0xd5] = 0x8b
            set data[0xd6] = 0x86
            set data[0xd7] = 0x91
            set data[0xd8] = 0xa8
            set data[0xd9] = 0xe3
            set data[0xda] = 0x3e
            set data[0xdb] = 0x42
            set data[0xdc] = 0xc6
            set data[0xdd] = 0x51
            set data[0xde] = 0xf3
            set data[0xdf] = 0xe
            set data[0xe0] = 0x12
            set data[0xe1] = 0x36
            set data[0xe2] = 0x5a
            set data[0xe3] = 0xee
            set data[0xe4] = 0x29
            set data[0xe5] = 0x7b
            set data[0xe6] = 0x8d
            set data[0xe7] = 0x8c
            set data[0xe8] = 0x8f
            set data[0xe9] = 0x8a
            set data[0xea] = 0x85
            set data[0xeb] = 0x94
            set data[0xec] = 0xa7
            set data[0xed] = 0xf2
            set data[0xee] = 0xd
            set data[0xef] = 0x17
            set data[0xf0] = 0x39
            set data[0xf1] = 0x4b
            set data[0xf2] = 0xdd
            set data[0xf3] = 0x7c
            set data[0xf4] = 0x84
            set data[0xf5] = 0x97
            set data[0xf6] = 0xa2
            set data[0xf7] = 0xfd
            set data[0xf8] = 0x1c
            set data[0xf9] = 0x24
            set data[0xfa] = 0x6c
            set data[0xfb] = 0xb4
            set data[0xfc] = 0xc7
            set data[0xfd] = 0x52
            set data[0xfe] = 0xf6
            set data[0xff] = 0x1
        endmethod
    endmodule
    
    struct etable extends array
        implement etablem
    endstruct
endlibrary