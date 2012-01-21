; ModuleID = 'mt19937-64-unsafe.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.0.0"

@mt = internal global [312 x i64] zeroinitializer, align 16
@mti = internal global i32 313, align 4
@genrand64_int64_unsafe.mag01 = internal global [2 x i64] [i64 0, i64 -5403634167711393303], align 16

define void @init_genrand64_unsafe(i64 %seed) nounwind uwtable ssp {
entry:
  %seed.addr = alloca i64, align 8
  store i64 %seed, i64* %seed.addr, align 8
  %0 = load i64* %seed.addr, align 8
  store i64 %0, i64* getelementptr inbounds ([312 x i64]* @mt, i32 0, i64 0), align 8
  store i32 1, i32* @mti, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %1 = load i32* @mti, align 4
  %cmp = icmp slt i32 %1, 312
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %2 = load i32* @mti, align 4
  %sub = sub nsw i32 %2, 1
  %idxprom = sext i32 %sub to i64
  %arrayidx = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom
  %3 = load i64* %arrayidx, align 8
  %4 = load i32* @mti, align 4
  %sub1 = sub nsw i32 %4, 1
  %idxprom2 = sext i32 %sub1 to i64
  %arrayidx3 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom2
  %5 = load i64* %arrayidx3, align 8
  %shr = lshr i64 %5, 62
  %xor = xor i64 %3, %shr
  %mul = mul i64 6364136223846793005, %xor
  %6 = load i32* @mti, align 4
  %conv = sext i32 %6 to i64
  %add = add i64 %mul, %conv
  %7 = load i32* @mti, align 4
  %idxprom4 = sext i32 %7 to i64
  %arrayidx5 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom4
  store i64 %add, i64* %arrayidx5, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %8 = load i32* @mti, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, i32* @mti, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

define i64 @genrand64_int64_unsafe() nounwind uwtable ssp {
entry:
  %i = alloca i32, align 4
  %x = alloca i64, align 8
  %0 = load i32* @mti, align 4
  %cmp = icmp sge i32 %0, 312
  br i1 %cmp, label %if.then, label %if.end53

if.then:                                          ; preds = %entry
  %1 = load i32* @mti, align 4
  %cmp1 = icmp eq i32 %1, 313
  br i1 %cmp1, label %if.then2, label %if.end

if.then2:                                         ; preds = %if.then
  call void @init_genrand64_unsafe(i64 5489)
  br label %if.end

if.end:                                           ; preds = %if.then2, %if.then
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %if.end
  %2 = load i32* %i, align 4
  %cmp3 = icmp slt i32 %2, 156
  br i1 %cmp3, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load i32* %i, align 4
  %idxprom = sext i32 %3 to i64
  %arrayidx = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom
  %4 = load i64* %arrayidx, align 8
  %and = and i64 %4, -2147483648
  %5 = load i32* %i, align 4
  %add = add nsw i32 %5, 1
  %idxprom4 = sext i32 %add to i64
  %arrayidx5 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom4
  %6 = load i64* %arrayidx5, align 8
  %and6 = and i64 %6, 2147483647
  %or = or i64 %and, %and6
  store i64 %or, i64* %x, align 8
  %7 = load i32* %i, align 4
  %add7 = add nsw i32 %7, 156
  %idxprom8 = sext i32 %add7 to i64
  %arrayidx9 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom8
  %8 = load i64* %arrayidx9, align 8
  %9 = load i64* %x, align 8
  %shr = lshr i64 %9, 1
  %xor = xor i64 %8, %shr
  %10 = load i64* %x, align 8
  %and10 = and i64 %10, 1
  %conv = trunc i64 %and10 to i32
  %idxprom11 = sext i32 %conv to i64
  %arrayidx12 = getelementptr inbounds [2 x i64]* @genrand64_int64_unsafe.mag01, i32 0, i64 %idxprom11
  %11 = load i64* %arrayidx12, align 8
  %xor13 = xor i64 %xor, %11
  %12 = load i32* %i, align 4
  %idxprom14 = sext i32 %12 to i64
  %arrayidx15 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom14
  store i64 %xor13, i64* %arrayidx15, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %13 = load i32* %i, align 4
  %inc = add nsw i32 %13, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  br label %for.cond16

for.cond16:                                       ; preds = %for.inc40, %for.end
  %14 = load i32* %i, align 4
  %cmp17 = icmp slt i32 %14, 311
  br i1 %cmp17, label %for.body19, label %for.end42

for.body19:                                       ; preds = %for.cond16
  %15 = load i32* %i, align 4
  %idxprom20 = sext i32 %15 to i64
  %arrayidx21 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom20
  %16 = load i64* %arrayidx21, align 8
  %and22 = and i64 %16, -2147483648
  %17 = load i32* %i, align 4
  %add23 = add nsw i32 %17, 1
  %idxprom24 = sext i32 %add23 to i64
  %arrayidx25 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom24
  %18 = load i64* %arrayidx25, align 8
  %and26 = and i64 %18, 2147483647
  %or27 = or i64 %and22, %and26
  store i64 %or27, i64* %x, align 8
  %19 = load i32* %i, align 4
  %add28 = add nsw i32 %19, -156
  %idxprom29 = sext i32 %add28 to i64
  %arrayidx30 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom29
  %20 = load i64* %arrayidx30, align 8
  %21 = load i64* %x, align 8
  %shr31 = lshr i64 %21, 1
  %xor32 = xor i64 %20, %shr31
  %22 = load i64* %x, align 8
  %and33 = and i64 %22, 1
  %conv34 = trunc i64 %and33 to i32
  %idxprom35 = sext i32 %conv34 to i64
  %arrayidx36 = getelementptr inbounds [2 x i64]* @genrand64_int64_unsafe.mag01, i32 0, i64 %idxprom35
  %23 = load i64* %arrayidx36, align 8
  %xor37 = xor i64 %xor32, %23
  %24 = load i32* %i, align 4
  %idxprom38 = sext i32 %24 to i64
  %arrayidx39 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom38
  store i64 %xor37, i64* %arrayidx39, align 8
  br label %for.inc40

for.inc40:                                        ; preds = %for.body19
  %25 = load i32* %i, align 4
  %inc41 = add nsw i32 %25, 1
  store i32 %inc41, i32* %i, align 4
  br label %for.cond16

for.end42:                                        ; preds = %for.cond16
  %26 = load i64* getelementptr inbounds ([312 x i64]* @mt, i32 0, i64 311), align 8
  %and43 = and i64 %26, -2147483648
  %27 = load i64* getelementptr inbounds ([312 x i64]* @mt, i32 0, i64 0), align 8
  %and44 = and i64 %27, 2147483647
  %or45 = or i64 %and43, %and44
  store i64 %or45, i64* %x, align 8
  %28 = load i64* getelementptr inbounds ([312 x i64]* @mt, i32 0, i64 155), align 8
  %29 = load i64* %x, align 8
  %shr46 = lshr i64 %29, 1
  %xor47 = xor i64 %28, %shr46
  %30 = load i64* %x, align 8
  %and48 = and i64 %30, 1
  %conv49 = trunc i64 %and48 to i32
  %idxprom50 = sext i32 %conv49 to i64
  %arrayidx51 = getelementptr inbounds [2 x i64]* @genrand64_int64_unsafe.mag01, i32 0, i64 %idxprom50
  %31 = load i64* %arrayidx51, align 8
  %xor52 = xor i64 %xor47, %31
  store i64 %xor52, i64* getelementptr inbounds ([312 x i64]* @mt, i32 0, i64 311), align 8
  store i32 0, i32* @mti, align 4
  br label %if.end53

if.end53:                                         ; preds = %for.end42, %entry
  %32 = load i32* @mti, align 4
  %inc54 = add nsw i32 %32, 1
  store i32 %inc54, i32* @mti, align 4
  %idxprom55 = sext i32 %32 to i64
  %arrayidx56 = getelementptr inbounds [312 x i64]* @mt, i32 0, i64 %idxprom55
  %33 = load i64* %arrayidx56, align 8
  store i64 %33, i64* %x, align 8
  %34 = load i64* %x, align 8
  %shr57 = lshr i64 %34, 29
  %and58 = and i64 %shr57, 6148914691236517205
  %35 = load i64* %x, align 8
  %xor59 = xor i64 %35, %and58
  store i64 %xor59, i64* %x, align 8
  %36 = load i64* %x, align 8
  %shl = shl i64 %36, 17
  %and60 = and i64 %shl, 8202884508482404352
  %37 = load i64* %x, align 8
  %xor61 = xor i64 %37, %and60
  store i64 %xor61, i64* %x, align 8
  %38 = load i64* %x, align 8
  %shl62 = shl i64 %38, 37
  %and63 = and i64 %shl62, -2270628950310912
  %39 = load i64* %x, align 8
  %xor64 = xor i64 %39, %and63
  store i64 %xor64, i64* %x, align 8
  %40 = load i64* %x, align 8
  %shr65 = lshr i64 %40, 43
  %41 = load i64* %x, align 8
  %xor66 = xor i64 %41, %shr65
  store i64 %xor66, i64* %x, align 8
  %42 = load i64* %x, align 8
  ret i64 %42
}

define double @genrand64_real2_unsafe() nounwind uwtable ssp {
entry:
  %call = call i64 @genrand64_int64_unsafe()
  %shr = lshr i64 %call, 11
  %conv = uitofp i64 %shr to double
  %mul = fmul double %conv, 0x3CA0000000000000
  ret double %mul
}
