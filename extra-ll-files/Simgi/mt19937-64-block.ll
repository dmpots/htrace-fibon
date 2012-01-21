; ModuleID = 'mt19937-64-block.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"
target triple = "x86_64-apple-darwin10.0.0"

%struct.mt_block_t = type { [312 x i64] }

@next_genrand64_block.mag01 = internal global [2 x i64] [i64 0, i64 -5403634167711393303], align 16

define void @seed_genrand64_block(%struct.mt_block_t* %st, i64 %seed) nounwind uwtable ssp {
entry:
  %st.addr = alloca %struct.mt_block_t*, align 8
  %seed.addr = alloca i64, align 8
  %i = alloca i32, align 4
  store %struct.mt_block_t* %st, %struct.mt_block_t** %st.addr, align 8
  store i64 %seed, i64* %seed.addr, align 8
  %0 = load i64* %seed.addr, align 8
  %1 = load %struct.mt_block_t** %st.addr, align 8
  %mt = getelementptr inbounds %struct.mt_block_t* %1, i32 0, i32 0
  %arrayidx = getelementptr inbounds [312 x i64]* %mt, i32 0, i64 0
  store i64 %0, i64* %arrayidx, align 8
  store i32 1, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %i, align 4
  %cmp = icmp slt i32 %2, 312
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %3 = load i32* %i, align 4
  %sub = sub nsw i32 %3, 1
  %idxprom = sext i32 %sub to i64
  %4 = load %struct.mt_block_t** %st.addr, align 8
  %mt1 = getelementptr inbounds %struct.mt_block_t* %4, i32 0, i32 0
  %arrayidx2 = getelementptr inbounds [312 x i64]* %mt1, i32 0, i64 %idxprom
  %5 = load i64* %arrayidx2, align 8
  %6 = load i32* %i, align 4
  %sub3 = sub nsw i32 %6, 1
  %idxprom4 = sext i32 %sub3 to i64
  %7 = load %struct.mt_block_t** %st.addr, align 8
  %mt5 = getelementptr inbounds %struct.mt_block_t* %7, i32 0, i32 0
  %arrayidx6 = getelementptr inbounds [312 x i64]* %mt5, i32 0, i64 %idxprom4
  %8 = load i64* %arrayidx6, align 8
  %shr = lshr i64 %8, 62
  %xor = xor i64 %5, %shr
  %mul = mul i64 6364136223846793005, %xor
  %9 = load i32* %i, align 4
  %conv = sext i32 %9 to i64
  %add = add i64 %mul, %conv
  %10 = load i32* %i, align 4
  %idxprom7 = sext i32 %10 to i64
  %11 = load %struct.mt_block_t** %st.addr, align 8
  %mt8 = getelementptr inbounds %struct.mt_block_t* %11, i32 0, i32 0
  %arrayidx9 = getelementptr inbounds [312 x i64]* %mt8, i32 0, i64 %idxprom7
  store i64 %add, i64* %arrayidx9, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %12 = load i32* %i, align 4
  %inc = add nsw i32 %12, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

define void @next_genrand64_block(%struct.mt_block_t* %st, %struct.mt_block_t* %newst) nounwind uwtable ssp {
entry:
  %st.addr = alloca %struct.mt_block_t*, align 8
  %newst.addr = alloca %struct.mt_block_t*, align 8
  %i = alloca i32, align 4
  %x = alloca i64, align 8
  store %struct.mt_block_t* %st, %struct.mt_block_t** %st.addr, align 8
  store %struct.mt_block_t* %newst, %struct.mt_block_t** %newst.addr, align 8
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32* %i, align 4
  %cmp = icmp slt i32 %0, 156
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32* %i, align 4
  %idxprom = sext i32 %1 to i64
  %2 = load %struct.mt_block_t** %st.addr, align 8
  %mt = getelementptr inbounds %struct.mt_block_t* %2, i32 0, i32 0
  %arrayidx = getelementptr inbounds [312 x i64]* %mt, i32 0, i64 %idxprom
  %3 = load i64* %arrayidx, align 8
  %and = and i64 %3, -2147483648
  %4 = load i32* %i, align 4
  %add = add nsw i32 %4, 1
  %idxprom1 = sext i32 %add to i64
  %5 = load %struct.mt_block_t** %st.addr, align 8
  %mt2 = getelementptr inbounds %struct.mt_block_t* %5, i32 0, i32 0
  %arrayidx3 = getelementptr inbounds [312 x i64]* %mt2, i32 0, i64 %idxprom1
  %6 = load i64* %arrayidx3, align 8
  %and4 = and i64 %6, 2147483647
  %or = or i64 %and, %and4
  store i64 %or, i64* %x, align 8
  %7 = load i32* %i, align 4
  %add5 = add nsw i32 %7, 156
  %idxprom6 = sext i32 %add5 to i64
  %8 = load %struct.mt_block_t** %st.addr, align 8
  %mt7 = getelementptr inbounds %struct.mt_block_t* %8, i32 0, i32 0
  %arrayidx8 = getelementptr inbounds [312 x i64]* %mt7, i32 0, i64 %idxprom6
  %9 = load i64* %arrayidx8, align 8
  %10 = load i64* %x, align 8
  %shr = lshr i64 %10, 1
  %xor = xor i64 %9, %shr
  %11 = load i64* %x, align 8
  %and9 = and i64 %11, 1
  %conv = trunc i64 %and9 to i32
  %idxprom10 = sext i32 %conv to i64
  %arrayidx11 = getelementptr inbounds [2 x i64]* @next_genrand64_block.mag01, i32 0, i64 %idxprom10
  %12 = load i64* %arrayidx11, align 8
  %xor12 = xor i64 %xor, %12
  %13 = load i32* %i, align 4
  %idxprom13 = sext i32 %13 to i64
  %14 = load %struct.mt_block_t** %newst.addr, align 8
  %mt14 = getelementptr inbounds %struct.mt_block_t* %14, i32 0, i32 0
  %arrayidx15 = getelementptr inbounds [312 x i64]* %mt14, i32 0, i64 %idxprom13
  store i64 %xor12, i64* %arrayidx15, align 8
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %15 = load i32* %i, align 4
  %inc = add nsw i32 %15, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  br label %for.cond16

for.cond16:                                       ; preds = %for.inc44, %for.end
  %16 = load i32* %i, align 4
  %cmp17 = icmp slt i32 %16, 311
  br i1 %cmp17, label %for.body19, label %for.end46

for.body19:                                       ; preds = %for.cond16
  %17 = load i32* %i, align 4
  %idxprom20 = sext i32 %17 to i64
  %18 = load %struct.mt_block_t** %st.addr, align 8
  %mt21 = getelementptr inbounds %struct.mt_block_t* %18, i32 0, i32 0
  %arrayidx22 = getelementptr inbounds [312 x i64]* %mt21, i32 0, i64 %idxprom20
  %19 = load i64* %arrayidx22, align 8
  %and23 = and i64 %19, -2147483648
  %20 = load i32* %i, align 4
  %add24 = add nsw i32 %20, 1
  %idxprom25 = sext i32 %add24 to i64
  %21 = load %struct.mt_block_t** %st.addr, align 8
  %mt26 = getelementptr inbounds %struct.mt_block_t* %21, i32 0, i32 0
  %arrayidx27 = getelementptr inbounds [312 x i64]* %mt26, i32 0, i64 %idxprom25
  %22 = load i64* %arrayidx27, align 8
  %and28 = and i64 %22, 2147483647
  %or29 = or i64 %and23, %and28
  store i64 %or29, i64* %x, align 8
  %23 = load i32* %i, align 4
  %add30 = add nsw i32 %23, -156
  %idxprom31 = sext i32 %add30 to i64
  %24 = load %struct.mt_block_t** %newst.addr, align 8
  %mt32 = getelementptr inbounds %struct.mt_block_t* %24, i32 0, i32 0
  %arrayidx33 = getelementptr inbounds [312 x i64]* %mt32, i32 0, i64 %idxprom31
  %25 = load i64* %arrayidx33, align 8
  %26 = load i64* %x, align 8
  %shr34 = lshr i64 %26, 1
  %xor35 = xor i64 %25, %shr34
  %27 = load i64* %x, align 8
  %and36 = and i64 %27, 1
  %conv37 = trunc i64 %and36 to i32
  %idxprom38 = sext i32 %conv37 to i64
  %arrayidx39 = getelementptr inbounds [2 x i64]* @next_genrand64_block.mag01, i32 0, i64 %idxprom38
  %28 = load i64* %arrayidx39, align 8
  %xor40 = xor i64 %xor35, %28
  %29 = load i32* %i, align 4
  %idxprom41 = sext i32 %29 to i64
  %30 = load %struct.mt_block_t** %newst.addr, align 8
  %mt42 = getelementptr inbounds %struct.mt_block_t* %30, i32 0, i32 0
  %arrayidx43 = getelementptr inbounds [312 x i64]* %mt42, i32 0, i64 %idxprom41
  store i64 %xor40, i64* %arrayidx43, align 8
  br label %for.inc44

for.inc44:                                        ; preds = %for.body19
  %31 = load i32* %i, align 4
  %inc45 = add nsw i32 %31, 1
  store i32 %inc45, i32* %i, align 4
  br label %for.cond16

for.end46:                                        ; preds = %for.cond16
  %32 = load %struct.mt_block_t** %st.addr, align 8
  %mt47 = getelementptr inbounds %struct.mt_block_t* %32, i32 0, i32 0
  %arrayidx48 = getelementptr inbounds [312 x i64]* %mt47, i32 0, i64 311
  %33 = load i64* %arrayidx48, align 8
  %and49 = and i64 %33, -2147483648
  %34 = load %struct.mt_block_t** %newst.addr, align 8
  %mt50 = getelementptr inbounds %struct.mt_block_t* %34, i32 0, i32 0
  %arrayidx51 = getelementptr inbounds [312 x i64]* %mt50, i32 0, i64 0
  %35 = load i64* %arrayidx51, align 8
  %and52 = and i64 %35, 2147483647
  %or53 = or i64 %and49, %and52
  store i64 %or53, i64* %x, align 8
  %36 = load %struct.mt_block_t** %newst.addr, align 8
  %mt54 = getelementptr inbounds %struct.mt_block_t* %36, i32 0, i32 0
  %arrayidx55 = getelementptr inbounds [312 x i64]* %mt54, i32 0, i64 155
  %37 = load i64* %arrayidx55, align 8
  %38 = load i64* %x, align 8
  %shr56 = lshr i64 %38, 1
  %xor57 = xor i64 %37, %shr56
  %39 = load i64* %x, align 8
  %and58 = and i64 %39, 1
  %conv59 = trunc i64 %and58 to i32
  %idxprom60 = sext i32 %conv59 to i64
  %arrayidx61 = getelementptr inbounds [2 x i64]* @next_genrand64_block.mag01, i32 0, i64 %idxprom60
  %40 = load i64* %arrayidx61, align 8
  %xor62 = xor i64 %xor57, %40
  %41 = load %struct.mt_block_t** %newst.addr, align 8
  %mt63 = getelementptr inbounds %struct.mt_block_t* %41, i32 0, i32 0
  %arrayidx64 = getelementptr inbounds [312 x i64]* %mt63, i32 0, i64 311
  store i64 %xor62, i64* %arrayidx64, align 8
  ret void
}

define i64 @mix_bits(i64 %x) nounwind uwtable ssp {
entry:
  %x.addr = alloca i64, align 8
  store i64 %x, i64* %x.addr, align 8
  %0 = load i64* %x.addr, align 8
  %shr = lshr i64 %0, 29
  %and = and i64 %shr, 6148914691236517205
  %1 = load i64* %x.addr, align 8
  %xor = xor i64 %1, %and
  store i64 %xor, i64* %x.addr, align 8
  %2 = load i64* %x.addr, align 8
  %shl = shl i64 %2, 17
  %and1 = and i64 %shl, 8202884508482404352
  %3 = load i64* %x.addr, align 8
  %xor2 = xor i64 %3, %and1
  store i64 %xor2, i64* %x.addr, align 8
  %4 = load i64* %x.addr, align 8
  %shl3 = shl i64 %4, 37
  %and4 = and i64 %shl3, -2270628950310912
  %5 = load i64* %x.addr, align 8
  %xor5 = xor i64 %5, %and4
  store i64 %xor5, i64* %x.addr, align 8
  %6 = load i64* %x.addr, align 8
  %shr6 = lshr i64 %6, 43
  %7 = load i64* %x.addr, align 8
  %xor7 = xor i64 %7, %shr6
  store i64 %xor7, i64* %x.addr, align 8
  %8 = load i64* %x.addr, align 8
  ret i64 %8
}
