; ModuleID = 'mt19937-64.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.0.0"

%struct.mt_state_t = type { [312 x i64], i32 }

@genrand64_int64.mag01 = internal global [2 x i64] [i64 0, i64 -5403634167711393303], align 16

define void @init_genrand64(%struct.mt_state_t* %st, i64 %seed) nounwind uwtable ssp {
entry:
  %st.addr = alloca %struct.mt_state_t*, align 8
  %seed.addr = alloca i64, align 8
  store %struct.mt_state_t* %st, %struct.mt_state_t** %st.addr, align 8
  store i64 %seed, i64* %seed.addr, align 8
  %0 = load %struct.mt_state_t** %st.addr, align 8
  %mti = getelementptr inbounds %struct.mt_state_t* %0, i32 0, i32 1
  store i32 313, i32* %mti, align 4
  %1 = load i64* %seed.addr, align 8
  %2 = load %struct.mt_state_t** %st.addr, align 8
  %mt = getelementptr inbounds %struct.mt_state_t* %2, i32 0, i32 0
  %arrayidx = getelementptr inbounds [312 x i64]* %mt, i32 0, i64 0
  store i64 %1, i64* %arrayidx, align 8
  %3 = load %struct.mt_state_t** %st.addr, align 8
  %mti1 = getelementptr inbounds %struct.mt_state_t* %3, i32 0, i32 1
  store i32 1, i32* %mti1, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %4 = load %struct.mt_state_t** %st.addr, align 8
  %mti2 = getelementptr inbounds %struct.mt_state_t* %4, i32 0, i32 1
  %5 = load i32* %mti2, align 4
  %cmp = icmp slt i32 %5, 312
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %6 = load %struct.mt_state_t** %st.addr, align 8
  %mti3 = getelementptr inbounds %struct.mt_state_t* %6, i32 0, i32 1
  %7 = load i32* %mti3, align 4
  %sub = sub nsw i32 %7, 1
  %idxprom = sext i32 %sub to i64
  %8 = load %struct.mt_state_t** %st.addr, align 8
  %mt4 = getelementptr inbounds %struct.mt_state_t* %8, i32 0, i32 0
  %arrayidx5 = getelementptr inbounds [312 x i64]* %mt4, i32 0, i64 %idxprom
  %9 = load i64* %arrayidx5, align 8
  %10 = load %struct.mt_state_t** %st.addr, align 8
  %mti6 = getelementptr inbounds %struct.mt_state_t* %10, i32 0, i32 1
  %11 = load i32* %mti6, align 4
  %sub7 = sub nsw i32 %11, 1
  %idxprom8 = sext i32 %sub7 to i64
  %12 = load %struct.mt_state_t** %st.addr, align 8
  %mt9 = getelementptr inbounds %struct.mt_state_t* %12, i32 0, i32 0
  %arrayidx10 = getelementptr inbounds [312 x i64]* %mt9, i32 0, i64 %idxprom8
  %13 = load i64* %arrayidx10, align 8
  %shr = lshr i64 %13, 62
  %xor = xor i64 %9, %shr
  %mul = mul i64 6364136223846793005, %xor
  %14 = load %struct.mt_state_t** %st.addr, align 8
  %mti11 = getelementptr inbounds %struct.mt_state_t* %14, i32 0, i32 1
  %15 = load i32* %mti11, align 4
  %conv = sext i32 %15 to i64
  %add = add i64 %mul, %conv
  %16 = load %struct.mt_state_t** %st.addr, align 8
  %mti12 = getelementptr inbounds %struct.mt_state_t* %16, i32 0, i32 1
  %17 = load i32* %mti12, align 4
  %idxprom13 = sext i32 %17 to i64
  %18 = load %struct.mt_state_t** %st.addr, align 8
  %mt14 = getelementptr inbounds %struct.mt_state_t* %18, i32 0, i32 0
  %arrayidx15 = getelementptr inbounds [312 x i64]* %mt14, i32 0, i64 %idxprom13
  store i64 %add, i64* %arrayidx15, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %19 = load %struct.mt_state_t** %st.addr, align 8
  %mti16 = getelementptr inbounds %struct.mt_state_t* %19, i32 0, i32 1
  %20 = load i32* %mti16, align 4
  %inc = add nsw i32 %20, 1
  store i32 %inc, i32* %mti16, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

define i64 @genrand64_int64(%struct.mt_state_t* %st) nounwind uwtable ssp {
entry:
  %st.addr = alloca %struct.mt_state_t*, align 8
  %i = alloca i32, align 4
  %x = alloca i64, align 8
  store %struct.mt_state_t* %st, %struct.mt_state_t** %st.addr, align 8
  %0 = load %struct.mt_state_t** %st.addr, align 8
  %mti = getelementptr inbounds %struct.mt_state_t* %0, i32 0, i32 1
  %1 = load i32* %mti, align 4
  %cmp = icmp sge i32 %1, 312
  br i1 %cmp, label %if.then, label %if.end70

if.then:                                          ; preds = %entry
  %2 = load %struct.mt_state_t** %st.addr, align 8
  %mti1 = getelementptr inbounds %struct.mt_state_t* %2, i32 0, i32 1
  %3 = load i32* %mti1, align 4
  %cmp2 = icmp eq i32 %3, 313
  br i1 %cmp2, label %if.then3, label %if.end

if.then3:                                         ; preds = %if.then
  %4 = load %struct.mt_state_t** %st.addr, align 8
  call void @init_genrand64(%struct.mt_state_t* %4, i64 5489)
  br label %if.end

if.end:                                           ; preds = %if.then3, %if.then
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %5 = load i32* %i, align 4
  %cmp4 = icmp slt i32 %5, 156
  br i1 %cmp4, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %6 = load i32* %i, align 4
  %idxprom = sext i32 %6 to i64
  %7 = load %struct.mt_state_t** %st.addr, align 8
  %mt = getelementptr inbounds %struct.mt_state_t* %7, i32 0, i32 0
  %arrayidx = getelementptr inbounds [312 x i64]* %mt, i32 0, i64 %idxprom
  %8 = load i64* %arrayidx, align 8
  %and = and i64 %8, -2147483648
  %9 = load i32* %i, align 4
  %add = add nsw i32 %9, 1
  %idxprom5 = sext i32 %add to i64
  %10 = load %struct.mt_state_t** %st.addr, align 8
  %mt6 = getelementptr inbounds %struct.mt_state_t* %10, i32 0, i32 0
  %arrayidx7 = getelementptr inbounds [312 x i64]* %mt6, i32 0, i64 %idxprom5
  %11 = load i64* %arrayidx7, align 8
  %and8 = and i64 %11, 2147483647
  %or = or i64 %and, %and8
  store i64 %or, i64* %x, align 8
  %12 = load i32* %i, align 4
  %add9 = add nsw i32 %12, 156
  %idxprom10 = sext i32 %add9 to i64
  %13 = load %struct.mt_state_t** %st.addr, align 8
  %mt11 = getelementptr inbounds %struct.mt_state_t* %13, i32 0, i32 0
  %arrayidx12 = getelementptr inbounds [312 x i64]* %mt11, i32 0, i64 %idxprom10
  %14 = load i64* %arrayidx12, align 8
  %15 = load i64* %x, align 8
  %shr = lshr i64 %15, 1
  %xor = xor i64 %14, %shr
  %16 = load i64* %x, align 8
  %and13 = and i64 %16, 1
  %conv = trunc i64 %and13 to i32
  %idxprom14 = sext i32 %conv to i64
  %arrayidx15 = getelementptr inbounds [2 x i64]* @genrand64_int64.mag01, i32 0, i64 %idxprom14
  %17 = load i64* %arrayidx15, align 8
  %xor16 = xor i64 %xor, %17
  %18 = load i32* %i, align 4
  %idxprom17 = sext i32 %18 to i64
  %19 = load %struct.mt_state_t** %st.addr, align 8
  %mt18 = getelementptr inbounds %struct.mt_state_t* %19, i32 0, i32 0
  %arrayidx19 = getelementptr inbounds [312 x i64]* %mt18, i32 0, i64 %idxprom17
  store i64 %xor16, i64* %arrayidx19, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %20 = load i32* %i, align 4
  %inc = add nsw i32 %20, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  br label %for.cond20

for.cond20:                                       ; preds = %for.inc48, %for.end
  %21 = load i32* %i, align 4
  %cmp21 = icmp slt i32 %21, 311
  br i1 %cmp21, label %for.body23, label %for.end50

for.body23:                                       ; preds = %for.cond20
  %22 = load i32* %i, align 4
  %idxprom24 = sext i32 %22 to i64
  %23 = load %struct.mt_state_t** %st.addr, align 8
  %mt25 = getelementptr inbounds %struct.mt_state_t* %23, i32 0, i32 0
  %arrayidx26 = getelementptr inbounds [312 x i64]* %mt25, i32 0, i64 %idxprom24
  %24 = load i64* %arrayidx26, align 8
  %and27 = and i64 %24, -2147483648
  %25 = load i32* %i, align 4
  %add28 = add nsw i32 %25, 1
  %idxprom29 = sext i32 %add28 to i64
  %26 = load %struct.mt_state_t** %st.addr, align 8
  %mt30 = getelementptr inbounds %struct.mt_state_t* %26, i32 0, i32 0
  %arrayidx31 = getelementptr inbounds [312 x i64]* %mt30, i32 0, i64 %idxprom29
  %27 = load i64* %arrayidx31, align 8
  %and32 = and i64 %27, 2147483647
  %or33 = or i64 %and27, %and32
  store i64 %or33, i64* %x, align 8
  %28 = load i32* %i, align 4
  %add34 = add nsw i32 %28, -156
  %idxprom35 = sext i32 %add34 to i64
  %29 = load %struct.mt_state_t** %st.addr, align 8
  %mt36 = getelementptr inbounds %struct.mt_state_t* %29, i32 0, i32 0
  %arrayidx37 = getelementptr inbounds [312 x i64]* %mt36, i32 0, i64 %idxprom35
  %30 = load i64* %arrayidx37, align 8
  %31 = load i64* %x, align 8
  %shr38 = lshr i64 %31, 1
  %xor39 = xor i64 %30, %shr38
  %32 = load i64* %x, align 8
  %and40 = and i64 %32, 1
  %conv41 = trunc i64 %and40 to i32
  %idxprom42 = sext i32 %conv41 to i64
  %arrayidx43 = getelementptr inbounds [2 x i64]* @genrand64_int64.mag01, i32 0, i64 %idxprom42
  %33 = load i64* %arrayidx43, align 8
  %xor44 = xor i64 %xor39, %33
  %34 = load i32* %i, align 4
  %idxprom45 = sext i32 %34 to i64
  %35 = load %struct.mt_state_t** %st.addr, align 8
  %mt46 = getelementptr inbounds %struct.mt_state_t* %35, i32 0, i32 0
  %arrayidx47 = getelementptr inbounds [312 x i64]* %mt46, i32 0, i64 %idxprom45
  store i64 %xor44, i64* %arrayidx47, align 8
  br label %for.inc48

for.inc48:                                        ; preds = %for.body23
  %36 = load i32* %i, align 4
  %inc49 = add nsw i32 %36, 1
  store i32 %inc49, i32* %i, align 4
  br label %for.cond20

for.end50:                                        ; preds = %for.cond20
  %37 = load %struct.mt_state_t** %st.addr, align 8
  %mt51 = getelementptr inbounds %struct.mt_state_t* %37, i32 0, i32 0
  %arrayidx52 = getelementptr inbounds [312 x i64]* %mt51, i32 0, i64 311
  %38 = load i64* %arrayidx52, align 8
  %and53 = and i64 %38, -2147483648
  %39 = load %struct.mt_state_t** %st.addr, align 8
  %mt54 = getelementptr inbounds %struct.mt_state_t* %39, i32 0, i32 0
  %arrayidx55 = getelementptr inbounds [312 x i64]* %mt54, i32 0, i64 0
  %40 = load i64* %arrayidx55, align 8
  %and56 = and i64 %40, 2147483647
  %or57 = or i64 %and53, %and56
  store i64 %or57, i64* %x, align 8
  %41 = load %struct.mt_state_t** %st.addr, align 8
  %mt58 = getelementptr inbounds %struct.mt_state_t* %41, i32 0, i32 0
  %arrayidx59 = getelementptr inbounds [312 x i64]* %mt58, i32 0, i64 155
  %42 = load i64* %arrayidx59, align 8
  %43 = load i64* %x, align 8
  %shr60 = lshr i64 %43, 1
  %xor61 = xor i64 %42, %shr60
  %44 = load i64* %x, align 8
  %and62 = and i64 %44, 1
  %conv63 = trunc i64 %and62 to i32
  %idxprom64 = sext i32 %conv63 to i64
  %arrayidx65 = getelementptr inbounds [2 x i64]* @genrand64_int64.mag01, i32 0, i64 %idxprom64
  %45 = load i64* %arrayidx65, align 8
  %xor66 = xor i64 %xor61, %45
  %46 = load %struct.mt_state_t** %st.addr, align 8
  %mt67 = getelementptr inbounds %struct.mt_state_t* %46, i32 0, i32 0
  %arrayidx68 = getelementptr inbounds [312 x i64]* %mt67, i32 0, i64 311
  store i64 %xor66, i64* %arrayidx68, align 8
  %47 = load %struct.mt_state_t** %st.addr, align 8
  %mti69 = getelementptr inbounds %struct.mt_state_t* %47, i32 0, i32 1
  store i32 0, i32* %mti69, align 4
  br label %if.end70

if.end70:                                         ; preds = %for.end50, %entry
  %48 = load %struct.mt_state_t** %st.addr, align 8
  %mti71 = getelementptr inbounds %struct.mt_state_t* %48, i32 0, i32 1
  %49 = load i32* %mti71, align 4
  %inc72 = add nsw i32 %49, 1
  store i32 %inc72, i32* %mti71, align 4
  %idxprom73 = sext i32 %49 to i64
  %50 = load %struct.mt_state_t** %st.addr, align 8
  %mt74 = getelementptr inbounds %struct.mt_state_t* %50, i32 0, i32 0
  %arrayidx75 = getelementptr inbounds [312 x i64]* %mt74, i32 0, i64 %idxprom73
  %51 = load i64* %arrayidx75, align 8
  store i64 %51, i64* %x, align 8
  %52 = load i64* %x, align 8
  %shr76 = lshr i64 %52, 29
  %and77 = and i64 %shr76, 6148914691236517205
  %53 = load i64* %x, align 8
  %xor78 = xor i64 %53, %and77
  store i64 %xor78, i64* %x, align 8
  %54 = load i64* %x, align 8
  %shl = shl i64 %54, 17
  %and79 = and i64 %shl, 8202884508482404352
  %55 = load i64* %x, align 8
  %xor80 = xor i64 %55, %and79
  store i64 %xor80, i64* %x, align 8
  %56 = load i64* %x, align 8
  %shl81 = shl i64 %56, 37
  %and82 = and i64 %shl81, -2270628950310912
  %57 = load i64* %x, align 8
  %xor83 = xor i64 %57, %and82
  store i64 %xor83, i64* %x, align 8
  %58 = load i64* %x, align 8
  %shr84 = lshr i64 %58, 43
  %59 = load i64* %x, align 8
  %xor85 = xor i64 %59, %shr84
  store i64 %xor85, i64* %x, align 8
  %60 = load i64* %x, align 8
  ret i64 %60
}

define double @genrand64_real2(%struct.mt_state_t* %st) nounwind uwtable ssp {
entry:
  %st.addr = alloca %struct.mt_state_t*, align 8
  store %struct.mt_state_t* %st, %struct.mt_state_t** %st.addr, align 8
  %0 = load %struct.mt_state_t** %st.addr, align 8
  %call = call i64 @genrand64_int64(%struct.mt_state_t* %0)
  %shr = lshr i64 %call, 11
  %conv = uitofp i64 %shr to double
  %mul = fmul double %conv, 0x3CA0000000000000
  ret double %mul
}
