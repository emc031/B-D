
######### input ########

cfg=$1
t0=$2

CONF_DIR="/lustre3/cd449/from_rd419/configs/l3296f211b630m0074m037m440-coul-v5/"
CONF="l3296f211b630m0074m037m440-coul.${cfg}"

#light & charm props

LIGHT_PROP_DIR="/lustre2/dc-mcle2/BtoD/3pt-exec/temp/"
LIGHT_PROP="l3296f211b630m0074m037m440-coul.${cfg}_wallprop_m0.0376_th0.0_t${t0}.binary"

CHARM_PROP_DIR="/lustre2/dc-mcle2/BtoD/3pt-exec/temp/"
CHARM_PROP="l3296f211b630m0074m037m440-coul.${cfg}_Rwallfull_m0.450_t${t0}"
CHARM_SMEAR_LABEL=( "l" "e" )

Nspace=32
NX=$Nspace
NY=$Nspace
NZ=$Nspace
NT=96

Tlist="14 19 24"
heavymass=1.91
charmmass=0.450
lightmass=0.0376
u0=0.8525

charmtwist=2.637 #3/4 of pmax = 3.516

####### output #########
CORR_DIR="/lustre2/dc-mcle2/BtoD/3pt-exec/correlators/set1_th2.637/"

cat << HERE
<ThreePointFunction>
  <NTIMES>3</NTIMES>
  <NMOMpi>1</NMOMpi>
  <NMOMpf>1</NMOMpf>
  <NMOMq>1</NMOMq>
  <Tlist>${Tlist}</Tlist>
  <Momenta_pi>
    <Momlist n="1">0 0 0</Momlist>
  </Momenta_pi>
  <Momenta_pf>
    <Momlist n="1">0 0 0</Momlist>
  </Momenta_pf>
  <Momenta_q>
    <Momlist n="1">0 0 0</Momlist>
  </Momenta_q>
  <Lx>${NX}</Lx>
  <Ly>${NY}</Ly>
  <Lz>${NZ}</Lz>
  <Lt>${NT}</Lt>
  <NQuarkSmearings>3</NQuarkSmearings>
  <NAQuarkSmearings>2</NAQuarkSmearings>
  <NCombos>6</NCombos>
  <QuarkCombos>1 2 3 1 2 3</QuarkCombos>
  <AntiQuarkCombos>1 1 1 2 2 2</AntiQuarkCombos>
  <ComboNames n="1">ll e1l e2l le e1e e2e</ComboNames>
  <Correlator_dir>${CORR_DIR}</Correlator_dir>
  <GaugeField>
    <Cfg_filename>${CONF}</Cfg_filename>
    <Cfg_directory>${CONF_DIR}</Cfg_directory>
    <Cfg_header_size>24</Cfg_header_size>
    <Cfg_format>MILCv5</Cfg_format>
    <u0>${u0}</u0>
    <tstart>${t0}</tstart>
    <Trev>false</Trev>
    <Twist>false</Twist>
    <Theta>0.0 0.0 0.0</Theta>
  </GaugeField>
  <QuarkPropagator Number="1">
    <Trev>false</Trev>
    <tstart>${t0}</tstart>
    <tlength>6</tlength>
    <Mass>${heavymass}</Mass>
    <nham>4</nham>
    <c1>1.21</c1>
    <c2>1.0</c2>
    <c3>1.0</c3>
    <c4>1.16</c4>
    <c5>1.12</c5>
    <c6>1.21</c6>
    <d1>None</d1>
    <d2>None</d2>
    <QuarkSource>exp</QuarkSource>
    <QuarkSourceRadius>3.425</QuarkSourceRadius>
    <generate_random_wall>false</generate_random_wall>
    <QuarkSourceFilename>None</QuarkSourceFilename>
    <RandomWall>true</RandomWall>
    <Seed>204</Seed>
    <HadronMomentum>0 0 0</HadronMomentum>
    <SourceMomentum>0 0 0</SourceMomentum>
    <WriteProp>false</WriteProp>
    <Filename>None</Filename>
  </QuarkPropagator>

  <QuarkPropagator Number="3">
    <Trev>false</Trev>
    <tstart>${t0}</tstart>
    <tlength>6</tlength>
    <Mass>${heavymass}</Mass>
    <nham>4</nham>
    <c1>1.21</c1>
    <c2>1.0</c2>
    <c3>1.0</c3>
    <c4>1.16</c4>
    <c5>1.12</c5>
    <c6>1.21</c6>
    <d1>None</d1>
    <d2>None</d2>
    <QuarkSource>exp</QuarkSource>
    <QuarkSourceRadius>6.85</QuarkSourceRadius>
    <generate_random_wall>false</generate_random_wall>
    <QuarkSourceFilename>None</QuarkSourceFilename>
    <RandomWall>true</RandomWall>
    <Seed>204</Seed>
    <HadronMomentum>0 0 0</HadronMomentum>
    <SourceMomentum>0 0 0</SourceMomentum>
    <WriteProp>false</WriteProp>
    <Filename>None</Filename>
  </QuarkPropagator>

  <LightQuarkPropagator Number="1">
    <Filename>${CHARM_PROP_DIR}${CHARM_PROP}_${CHARM_SMEAR_LABEL[0]}.binary</Filename>
    <Format>SciDACBinary</Format>
    <Trev>false</Trev>
    <tstart>${t0}</tstart>
    <tlength>6</tlength>
    <Mass>${charmmass}</Mass>
    <Meson>D</Meson>
    <QuarkSource>loc</QuarkSource>
    <QuarkSourceRadius>0.0</QuarkSourceRadius>
    <RandomWall>true</RandomWall>
    <Seed>${cfg}</Seed>
    <HadronMomentum>0 0 0</HadronMomentum>
    <SourceMomentum>0 0 0</SourceMomentum>
    <WriteProp>false</WriteProp>
    <theta>${charmtwist} ${charmtwist} ${charmtwist}</theta>
  </LightQuarkPropagator>

  <LightQuarkPropagator Number="2">
    <Filename>${CHARM_PROP_DIR}${CHARM_PROP}_${CHARM_SMEAR_LABEL[1]}.binary</Filename>
    <Format>SciDACBinary</Format>
    <Trev>false</Trev>
    <tstart>${t0}</tstart>
    <tlength>6</tlength>
    <Mass>${charmmass}</Mass>
    <Meson>D</Meson>
    <QuarkSource>exp</QuarkSource>
    <QuarkSourceRadius>3.425</QuarkSourceRadius>
    <RandomWall>true</RandomWall>
    <Seed>${cfg}</Seed>
    <HadronMomentum>0 0 0</HadronMomentum>
    <SourceMomentum>0 0 0</SourceMomentum>
    <WriteProp>false</WriteProp>
    <theta>${charmtwist} ${charmtwist} ${charmtwist}</theta>
  </LightQuarkPropagator>

  <SpectatorQuarkPropagator Number="1">
    <Filename>${LIGHT_PROP_DIR}${LIGHT_PROP}</Filename>
    <Format>SciDACBinary</Format>
    <Trev>false</Trev>
    <tstart>${t0}</tstart>
    <tlength>6</tlength>
    <Mass>${lightmass}</Mass>
    <Meson>D</Meson>
    <QuarkSource>loc</QuarkSource>
    <QuarkSourceRadius>0.0</QuarkSourceRadius>
    <RandomWall>true</RandomWall>
    <Seed>${cfg}</Seed>
    <HadronMomentum>0 0 0</HadronMomentum>
    <SourceMomentum>0 0 0</SourceMomentum>
    <WriteProp>false</WriteProp>
    <theta>0 0 0</theta>
  </SpectatorQuarkPropagator>
</ThreePointFunction>
HERE
