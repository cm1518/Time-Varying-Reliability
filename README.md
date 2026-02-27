## Replication package for "Time-varying reliability: Understanding identification in macroeconomics" by Pooyan Amir-Ahmadi, Christian Matthes & Mu-Chun Wang (forthcoming, Journal of Applied Econometrics)

Replication package tested on a Windows 11 machine with MATLAB 2024b

US data is contained in '/4. Data/data_combined.txt' 

UK data is contained in '/4. Data/uk_data_combined.txt'

Install Dynare 4.5.4. The default installation folder should be '/2. Codes/4.5.4/'

1. Generate estimation results first with running:

`run_estimations.m`

`run_estimations_MS.m`

2. Generate Monte Carlo results, make sure that the parallel computing toolbox is properly configured and the pool is up and running

`run_MCs.m`

`run_MCs_resub.m`

3. Generate figures from the main text with

`figure1_paper.m`

`figure2_paper.m`

...

4. Generate figures from the appendix with

`figureA1.m`

`figureA2.m`

...


AUTHORS: Pooyan Amir-Ahmadi, Christian Matthes, and Mu-Chun Wang

CONTACT: mu-chun.wang@bundesbank.de


Date: Feb 26 2026



