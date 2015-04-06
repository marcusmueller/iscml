# CML Features #

## Channel Coding ##

  * Rate 1/n convolutional codes
    * Decoding: log-MAP and linear log-MAP soft-in/soft-out (SISO), Viterbi soft-in/hard-out

  * Tail-biting convolutional codes.

  * Convolutional turbo codes (CTCS)
    * Binary CTCs with terminated trellises
    * Duo-binary tail-biting turbo codes

  * Block turbo codes (BTCs).

  * Low density parity check (LDPC) codes, decoding and encoding (encoding limited to certain classes of LDPC codes).
    * Supports user-specified parity check matrices

  * Puncturing and rate-matching to change the base code rate to a desired rate.

  * Binary cyclic block codes
    * Golay, Hamming, etc
    * Decoding: log-MAP (APP) and Viterbi

  * Generation of s-random (spread) interleaver and interleavers conforming to UMTS, LTE, cdma2000, CCSDS,  IEEE 802.16 and DVB-RCS standards.

## Modulation ##
  * Complex modulation formats with soft-in/soft-out (SISO) demodulation
    * M-PSK
    * APSK
    * QAM

  * M-FSK modulation
    * arbitrary modulation index (orthogonal or nonorthogonal)
    * Coherent or noncoherent demodulation

  * Iterative demodulation and decoding
    * Bit-interleaved coded modulation (BICM)
    * Bit interleaved coded modulation with iterative decoding (BICM-ID)


## Channel Modeling ##

  * Channel types supported
    * AWGN
    * Fully-interleaved (ergodic) Rayleigh fading
    * Block Rayleigh fading


## Information Theoretic Metrics ##
  * Monte Carlo computation of
    * Modulation constrained channel capacity in AWGN and ergodic fading
    * Information outage probability in block fading

  * Calculation of throughput of hybrid-ARQ systems


## Physical-layer Network Coding ##

  * Error-rate and capacity simulation of physical-layer network coding (PNC) in the two-way relay channel (TWRC)
    * Modulation supported: M-FSK, coherent and noncoherent
    * Decoding of Turbo and LDPC channel codes in the source-relay phase (decode and forward)
    * BICM and BICM-ID decoding frameworks supported

## Misc ##

  * High-performance simulation of error rate using a computing cluster.





# Standards #

The following functionality based on communication standards are given as examples

  * IEEE 802.16e (mobile WiMax)
    * tail-biting convolutional code
    * convolutional turbo code (CTC)
    * block turbo code (BTC)
    * LDPC code

  * DVB-RCS
    * turbo code

  * DVB-S2
    * LDPC code

  * UMTS (WCDMA)
    * turbo code

  * HSDPA
    * hybrid-ARQ using a rate-matched UMTS turbo code and QPSK/16-QAM   modulation.

  * LTE
    * turbo code

  * CCSDS
    * turbo code

  * cdma2000
    * turbo code