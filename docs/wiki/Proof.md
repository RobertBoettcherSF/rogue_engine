# Proof & SPARK policy

Today: strong Ada types, contracts, `-gnatwa`, and tests. Solid sim hygiene — **not** a proved flight computer yet.

## Floor (where IRL would want assurance)

Target **SPARK Level 2** on:

| Area | Packages / concerns |
|------|---------------------|
| Breathe / tissue O2 | `Game_Actors` human path, cabin/suit air |
| Suit / helmet | EVA worn mass, seal, suit-loop P/O2 timers |
| Airlock | Both-open invariant, cycle |
| ECLSS cabin tick | CO2 scrub / O2 make-up rates from Physical_Data |
| Strider remote-link | Console link safety (drop on power/range loss) |

UI, content loaders, wiki, and art stay **plain Ada**.

## Climb candidates (mark now, prove later)

The same IRL-critical set is marked **Level 3–4 candidates** so we can raise the bar without guessing:

breathe · suit/helmet · airlock · ECLSS · strider-link

ADA marks these in package headers; Ops keeps this page + the board POLICY card in sync.

## Rule

1. Ship features in Ada first if L2 would block play.
2. Before claiming IRL-grade assurance on a package, close at least **L2**.
3. L3/L4 only when Robert asks to climb that package.
