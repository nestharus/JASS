library ltable
    /*
        readonly integer array ltable
    
            02.d4 = ltable[02] + ltable[d4]
            if (result > ff) result = result - ff
            result = etable[result]
        
            samiam.org/galois.html
            
            table provided by intel
    
           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        0    00 19 01 32 02 1A C6 4B C7 1B 68 33 EE DF 03
        1 64 04 E0 0E 34 8D 81 EF 4C 71 08 C8 F8 69 1C C1
        2 7D C2 1D B5 F9 B9 27 6A 4D E4 A6 72 9A C9 09 78
        3 65 2F 8A 05 21 0F E1 24 12 F0 82 45 35 93 DA 8E
        4 96 8F DB BD 36 D0 CE 94 13 5C D2 F1 40 46 83 38
        5 66 DD FD 30 BF 06 8B 62 B3 25 E2 98 22 88 91 10
        6 7E 6E 48 C3 A3 B6 1E 42 3A 6B 28 54 FA 85 3D BA
        7 2B 79 0A 15 9B 9F 5E CA 4E D4 AC E5 F3 73 A7 57
        8 AF 58 A8 50 F4 EA D6 74 4F AE E9 D5 E7 E6 AD E8
        9 2C D7 75 7A EB 16 0B F5 59 CB 5F B0 9C A9 51 A0
        A 7F 0C F6 6F 17 C4 49 EC D8 43 1F 2D A4 76 7B B7
        B CC BB 3E 5A FB 60 B1 86 3B 52 A1 6C AA 55 29 9D
        C 97 B2 87 90 61 BE DC FC BC 95 CF CD 37 3F 5B D1
        D 53 39 84 3C 41 A2 6D 47 14 2A 9E 5D 56 F2 D3 AB
        E 44 11 92 D9 23 20 2E 89 B4 7C B8 26 77 99 E3 A5
        F 67 4A ED DE C5 31 FE 18 0D 63 8C 80 C0 F7 70 07
    */
    
    private module ltablem
        private static integer array data
        
        static constant method operator [] takes integer val returns integer
            return data[val]
        endmethod
        
        private static method onInit takes nothing returns nothing
            set data[0x1] = 0x0
            set data[0x2] = 0x19
            set data[0x3] = 0x1
            set data[0x4] = 0x32
            set data[0x5] = 0x2
            set data[0x6] = 0x1a
            set data[0x7] = 0xc6
            set data[0x8] = 0x4b
            set data[0x9] = 0xc7
            set data[0xa] = 0x1b
            set data[0xb] = 0x68
            set data[0xc] = 0x33
            set data[0xd] = 0xee
            set data[0xe] = 0xdf
            set data[0xf] = 0x3
            set data[0x10] = 0x64
            set data[0x11] = 0x4
            set data[0x12] = 0xe0
            set data[0x13] = 0xe
            set data[0x14] = 0x34
            set data[0x15] = 0x8d
            set data[0x16] = 0x81
            set data[0x17] = 0xef
            set data[0x18] = 0x4c
            set data[0x19] = 0x71
            set data[0x1a] = 0x8
            set data[0x1b] = 0xc8
            set data[0x1c] = 0xf8
            set data[0x1d] = 0x69
            set data[0x1e] = 0x1c
            set data[0x1f] = 0xc1
            set data[0x20] = 0x7d
            set data[0x21] = 0xc2
            set data[0x22] = 0x1d
            set data[0x23] = 0xb5
            set data[0x24] = 0xf9
            set data[0x25] = 0xb9
            set data[0x26] = 0x27
            set data[0x27] = 0x6a
            set data[0x28] = 0x4d
            set data[0x29] = 0xe4
            set data[0x2a] = 0xa6
            set data[0x2b] = 0x72
            set data[0x2c] = 0x9a
            set data[0x2d] = 0xc9
            set data[0x2e] = 0x9
            set data[0x2f] = 0x78
            set data[0x30] = 0x65
            set data[0x31] = 0x2f
            set data[0x32] = 0x8a
            set data[0x33] = 0x5
            set data[0x34] = 0x21
            set data[0x35] = 0xf
            set data[0x36] = 0xe1
            set data[0x37] = 0x24
            set data[0x38] = 0x12
            set data[0x39] = 0xf0
            set data[0x3a] = 0x82
            set data[0x3b] = 0x45
            set data[0x3c] = 0x35
            set data[0x3d] = 0x93
            set data[0x3e] = 0xda
            set data[0x3f] = 0x8e
            set data[0x40] = 0x96
            set data[0x41] = 0x8f
            set data[0x42] = 0xdb
            set data[0x43] = 0xbd
            set data[0x44] = 0x36
            set data[0x45] = 0xd0
            set data[0x46] = 0xce
            set data[0x47] = 0x94
            set data[0x48] = 0x13
            set data[0x49] = 0x5c
            set data[0x4a] = 0xd2
            set data[0x4b] = 0xf1
            set data[0x4c] = 0x40
            set data[0x4d] = 0x46
            set data[0x4e] = 0x83
            set data[0x4f] = 0x38
            set data[0x50] = 0x66
            set data[0x51] = 0xdd
            set data[0x52] = 0xfd
            set data[0x53] = 0x30
            set data[0x54] = 0xbf
            set data[0x55] = 0x6
            set data[0x56] = 0x8b
            set data[0x57] = 0x62
            set data[0x58] = 0xb3
            set data[0x59] = 0x25
            set data[0x5a] = 0xe2
            set data[0x5b] = 0x98
            set data[0x5c] = 0x22
            set data[0x5d] = 0x88
            set data[0x5e] = 0x91
            set data[0x5f] = 0x10
            set data[0x60] = 0x7e
            set data[0x61] = 0x6e
            set data[0x62] = 0x48
            set data[0x63] = 0xc3
            set data[0x64] = 0xa3
            set data[0x65] = 0xb6
            set data[0x66] = 0x1e
            set data[0x67] = 0x42
            set data[0x68] = 0x3a
            set data[0x69] = 0x6b
            set data[0x6a] = 0x28
            set data[0x6b] = 0x54
            set data[0x6c] = 0xfa
            set data[0x6d] = 0x85
            set data[0x6e] = 0x3d
            set data[0x6f] = 0xba
            set data[0x70] = 0x2b
            set data[0x71] = 0x79
            set data[0x72] = 0xa
            set data[0x73] = 0x15
            set data[0x74] = 0x9b
            set data[0x75] = 0x9f
            set data[0x76] = 0x5e
            set data[0x77] = 0xca
            set data[0x78] = 0x4e
            set data[0x79] = 0xd4
            set data[0x7a] = 0xac
            set data[0x7b] = 0xe5
            set data[0x7c] = 0xf3
            set data[0x7d] = 0x73
            set data[0x7e] = 0xa7
            set data[0x7f] = 0x57
            set data[0x80] = 0xaf
            set data[0x81] = 0x58
            set data[0x82] = 0xa8
            set data[0x83] = 0x50
            set data[0x84] = 0xf4
            set data[0x85] = 0xea
            set data[0x86] = 0xd6
            set data[0x87] = 0x74
            set data[0x88] = 0x4f
            set data[0x89] = 0xae
            set data[0x8a] = 0xe9
            set data[0x8b] = 0xd5
            set data[0x8c] = 0xe7
            set data[0x8d] = 0xe6
            set data[0x8e] = 0xad
            set data[0x8f] = 0xe8
            set data[0x90] = 0x2c
            set data[0x91] = 0xd7
            set data[0x92] = 0x75
            set data[0x93] = 0x7a
            set data[0x94] = 0xeb
            set data[0x95] = 0x16
            set data[0x96] = 0xb
            set data[0x97] = 0xf5
            set data[0x98] = 0x59
            set data[0x99] = 0xcb
            set data[0x9a] = 0x5f
            set data[0x9b] = 0xb0
            set data[0x9c] = 0x9c
            set data[0x9d] = 0xa9
            set data[0x9e] = 0x51
            set data[0x9f] = 0xa0
            set data[0xa0] = 0x7f
            set data[0xa1] = 0xc
            set data[0xa2] = 0xf6
            set data[0xa3] = 0x6f
            set data[0xa4] = 0x17
            set data[0xa5] = 0xc4
            set data[0xa6] = 0x49
            set data[0xa7] = 0xec
            set data[0xa8] = 0xd8
            set data[0xa9] = 0x43
            set data[0xaa] = 0x1f
            set data[0xab] = 0x2d
            set data[0xac] = 0xa4
            set data[0xad] = 0x76
            set data[0xae] = 0x7b
            set data[0xaf] = 0xb7
            set data[0xb0] = 0xcc
            set data[0xb1] = 0xbb
            set data[0xb2] = 0x3e
            set data[0xb3] = 0x5a
            set data[0xb4] = 0xfb
            set data[0xb5] = 0x60
            set data[0xb6] = 0xb1
            set data[0xb7] = 0x86
            set data[0xb8] = 0x3b
            set data[0xb9] = 0x52
            set data[0xba] = 0xa1
            set data[0xbb] = 0x6c
            set data[0xbc] = 0xaa
            set data[0xbd] = 0x55
            set data[0xbe] = 0x29
            set data[0xbf] = 0x9d
            set data[0xc0] = 0x97
            set data[0xc1] = 0xb2
            set data[0xc2] = 0x87
            set data[0xc3] = 0x90
            set data[0xc4] = 0x61
            set data[0xc5] = 0xbe
            set data[0xc6] = 0xdc
            set data[0xc7] = 0xfc
            set data[0xc8] = 0xbc
            set data[0xc9] = 0x95
            set data[0xca] = 0xcf
            set data[0xcb] = 0xcd
            set data[0xcc] = 0x37
            set data[0xcd] = 0x3f
            set data[0xce] = 0x5b
            set data[0xcf] = 0xd1
            set data[0xd0] = 0x53
            set data[0xd1] = 0x39
            set data[0xd2] = 0x84
            set data[0xd3] = 0x3c
            set data[0xd4] = 0x41
            set data[0xd5] = 0xa2
            set data[0xd6] = 0x6d
            set data[0xd7] = 0x47
            set data[0xd8] = 0x14
            set data[0xd9] = 0x2a
            set data[0xda] = 0x9e
            set data[0xdb] = 0x5d
            set data[0xdc] = 0x56
            set data[0xdd] = 0xf2
            set data[0xde] = 0xd3
            set data[0xdf] = 0xab
            set data[0xe0] = 0x44
            set data[0xe1] = 0x11
            set data[0xe2] = 0x92
            set data[0xe3] = 0xd9
            set data[0xe4] = 0x23
            set data[0xe5] = 0x20
            set data[0xe6] = 0x2e
            set data[0xe7] = 0x89
            set data[0xe8] = 0xb4
            set data[0xe9] = 0x7c
            set data[0xea] = 0xb8
            set data[0xeb] = 0x26
            set data[0xec] = 0x77
            set data[0xed] = 0x99
            set data[0xee] = 0xe3
            set data[0xef] = 0xa5
            set data[0xf0] = 0x67
            set data[0xf1] = 0x4a
            set data[0xf2] = 0xed
            set data[0xf3] = 0xde
            set data[0xf4] = 0xc5
            set data[0xf5] = 0x31
            set data[0xf6] = 0xfe
            set data[0xf7] = 0x18
            set data[0xf8] = 0xd
            set data[0xf9] = 0x63
            set data[0xfa] = 0x8c
            set data[0xfb] = 0x80
            set data[0xfc] = 0xc0
            set data[0xfd] = 0xf7
            set data[0xfe] = 0x70
            set data[0xff] = 0x7
        endmethod
    endmodule
    
    struct ltable extends array
        implement ltablem
    endstruct
endlibrary