/*
 *  Copyright (C) 2022 Texas Instruments Incorporated
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *    Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the
 *    distribution.
 *
 *    Neither the name of Texas Instruments Incorporated nor the names of
 *    its contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "unify/pcie.h"
#include <ti/csl/soc.h>
#include "unify/SystemP.h"

#include <ti/csl/csl_serdes.h>
#include <ti/csl/csl_serdes_pcie.h>

#include "unify/pcie_wrapper.h"

#include <ti/csl/cslr.h>

/* Number of PCIe instances */
#define PCIE_DEVICE_COUNT 3

#define SERDES_LANE_MASK  (0x3U)

/* Initialize Serdes corresponding to the PCIe device */
int32_t Pcie_serdesInit(Pcie_Handle handle, uint32_t deviceNum)
{
    int32_t status = SystemP_FAILURE;
    uint32_t serdesInst;
    uint32_t i, laneNum;
    CSL_SerdesLaneEnableParams serdesLaneEnableParams;

    Pcie_Config *pcieCfg;
    uint32_t pcieGen;
    uint32_t linkRate;

    DebugP_assert(PCIE_DEVICE_COUNT > deviceNum);

    memset(&serdesLaneEnableParams, 0, sizeof(serdesLaneEnableParams));
    DebugP_log("%s %d device num = %d\n", __func__, __LINE__, deviceNum);
    switch(deviceNum){
        case 0:
            serdesInst = CSL_TORRENT_SERDES1;
            serdesLaneEnableParams.baseAddr = CSL_WIZ16B8M4CT3_1_WIZ16B8M4CT3_BASE;
            break;
        case 1:
            serdesInst = CSL_TORRENT_SERDES0;
            serdesLaneEnableParams.baseAddr = CSL_WIZ16B8M4CT3_0_WIZ16B8M4CT3_BASE;
            break;
        default:
            return status;
    }
    DebugP_log("%s %d serdes inst = %d\n", __func__, __LINE__, serdesInst);
    serdesLaneEnableParams.serdesInstance = (CSL_SerdesInstance)serdesInst;

    pcieCfg = (Pcie_Config *)handle;
    pcieGen = pcieCfg->attrs->gen;

    DebugP_log("%s %d pcie gen = %d\n", __func__, __LINE__, pcieGen);
    switch (pcieGen)
    {
        case (PCIE_GEN1):
             DebugP_log("%s %d pcie gen = %d\n", __func__, __LINE__, pcieGen);
            linkRate = CSL_SERDES_LINK_RATE_3p125G;
            break;

        case (PCIE_GEN2):
            linkRate = CSL_SERDES_LINK_RATE_5G;
            break;

        /* Set lowest speed as default */
        default:
            linkRate = CSL_SERDES_LINK_RATE_3p125G;
            break;
    }

    serdesLaneEnableParams.refClock         = CSL_SERDES_REF_CLOCK_100M;
    serdesLaneEnableParams.refClkSrc        = CSL_SERDES_REF_CLOCK_INT0;
    serdesLaneEnableParams.linkRate         = linkRate;
    serdesLaneEnableParams.numLanes         = pcieCfg->attrs->numLanes;
    serdesLaneEnableParams.laneMask         = SERDES_LANE_MASK;
    serdesLaneEnableParams.SSC_mode         = CSL_SERDES_NO_SSC;
    serdesLaneEnableParams.phyType          = CSL_SERDES_PHY_TYPE_PCIe;
    serdesLaneEnableParams.pcieGenType      = pcieGen;
    serdesLaneEnableParams.operatingMode    = CSL_SERDES_FUNCTIONAL_MODE;
    serdesLaneEnableParams.phyInstanceNum   = deviceNum;
    serdesLaneEnableParams.refClkOut        = CSL_SERDES_REFCLK_OUT_EN;

    for(i = 0; i< serdesLaneEnableParams.numLanes; i++)
    {
        serdesLaneEnableParams.laneCtrlRate[i] = CSL_SERDES_LANE_FULL_RATE;
        serdesLaneEnableParams.loopbackMode[i] = CSL_SERDES_LOOPBACK_DISABLED; /* still have to change to correct loopback mode */
    }

    /* pcie_gen_type = SERDES_DIAG_TEST_PCIE_GEN_TYPE; */

    CSL_serdesPorReset(serdesLaneEnableParams.baseAddr);

    /* Select the IP type, IP instance num, Serdes Lane Number */
    for (laneNum = 0; laneNum < serdesLaneEnableParams.numLanes; laneNum++)
    {
        CSL_serdesIPSelect(CSL_CTRL_MMR0_CFG0_BASE,
                           serdesLaneEnableParams.phyType,
                           serdesLaneEnableParams.phyInstanceNum,
                           serdesLaneEnableParams.serdesInstance,
                           laneNum);
    }

    /* selects the appropriate clocks for all serdes based on the protocol chosen */
    status = CSL_serdesRefclkSel(CSL_CTRL_MMR0_CFG0_BASE,
                                  serdesLaneEnableParams.baseAddr,
                                  serdesLaneEnableParams.refClock,
                                  serdesLaneEnableParams.refClkSrc,
                                  serdesLaneEnableParams.serdesInstance,
                                  serdesLaneEnableParams.phyType);

    DebugP_log("%s %d status = %d\n", __func__, __LINE__, status);
    /* Return error if input params are invalid */
    DebugP_assert(status == CSL_SERDES_NO_ERR);

    /* Assert PHY reset and disable all lanes */
    CSL_serdesDisablePllAndLanes(serdesLaneEnableParams.baseAddr, serdesLaneEnableParams.numLanes, serdesLaneEnableParams.laneMask);

    /*Load the Serdes Config File */
    status = CSL_serdesPCIeInit(&serdesLaneEnableParams); /* Use this for PCIe serdes config load */

    /* Return error if input params are invalid */
    DebugP_assert(status == CSL_SERDES_NO_ERR);

    /* Set this to standard mode defined by Cadence */
    for (laneNum=0; laneNum < serdesLaneEnableParams.numLanes; laneNum++)
    {
        CSL_serdesPCIeModeSelect(serdesLaneEnableParams.baseAddr, serdesLaneEnableParams.pcieGenType, laneNum);
    }

    /* Common Lane Enable API for lane enable, pll enable etc */
    status = CSL_serdesLaneEnable(&serdesLaneEnableParams);

    DebugP_assert(CSL_SERDES_LANE_ENABLE_NO_ERR == status);

    return status;
}
