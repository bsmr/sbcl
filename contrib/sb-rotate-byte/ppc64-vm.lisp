(in-package "SB-ROTATE-BYTE")

(define-vop (%32bit-rotate-byte/c)
  (:policy :fast-safe)
  (:translate %unsigned-32-rotate-byte)
  (:note "inline 32-bit constant rotation")
  (:info count)
  (:args (integer :scs (sb-vm::unsigned-reg) :target res))
  (:arg-types (:constant (integer -31 31)) sb-vm::unsigned-num)
  (:results (res :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 1
    ;; the 0 case is an identity operation and should be
    ;; DEFTRANSFORMed away.
    (aver (not (= count 0)))
    (if (> count 0)
        (inst rotlwi res integer count)
        (inst rotrwi res integer (- count)))))

(define-vop (%64bit-rotate-byte/c)
  (:policy :fast-safe)
  (:translate %unsigned-64-rotate-byte)
  (:note "inline 64-bit constant rotation")
  (:args (integer :scs (sb-vm::unsigned-reg) :target res))
  (:info count)
  (:arg-types (:constant (integer -63 63)) sb-vm::unsigned-num)
  (:results (res :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 1
    (aver (not (= count 0)))
    (if (> count 0)
        (inst rotldi res integer count)
        (inst rotrdi res integer (- count)))))

(define-vop (%32bit-rotate-byte)
  (:policy :fast-safe)
  (:translate %unsigned-32-rotate-byte)
  (:note "inline 32-bit rotation")
  (:args (count :scs (sb-vm::signed-reg))
         (integer :scs (sb-vm::unsigned-reg) :target res))
  (:arg-types sb-vm::tagged-num sb-vm::unsigned-num)
  (:temporary (:scs (sb-vm::unsigned-reg) :from (:argument 0)) pluscount)
  (:results (res :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 6
    (inst cmpdi count 0)
    (inst bge rotate-left)
    (inst addi pluscount count 32)
    (inst rotlw res integer pluscount)
    (inst b end)
    ROTATE-LEFT
    (inst rotlw res integer count)
    END))

(define-vop (%64bit-rotate-byte)
  (:policy :fast-safe)
  (:translate %unsigned-64-rotate-byte)
  (:note "inline 64-bit rotation")
  (:args (count :scs (sb-vm::signed-reg))
         (integer :scs (sb-vm::unsigned-reg) :target res))
  (:arg-types sb-vm::tagged-num sb-vm::unsigned-num)
  (:temporary (:scs (sb-vm::unsigned-reg) :from (:argument 0)) pluscount)
  (:results (res :scs (sb-vm::unsigned-reg)))
  (:result-types sb-vm::unsigned-num)
  (:generator 6
    (inst cmpdi count 0)
    (inst bge rotate-left)
    (inst addi pluscount count 64)
    (inst rotld res integer pluscount)
    (inst b end)
    ROTATE-LEFT
    (inst rotld res integer count)
    END))