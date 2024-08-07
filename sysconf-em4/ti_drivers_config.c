/*
 *  Copyright (C) 2021 Texas Instruments Incorporated
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
/*
 * Auto generated file
 */

#include "ti_drivers_config.h"
#include <drivers/sciclient.h>

#include "unify/pcie_wrapper.h"

// /*
//  * IPC Notify
//  */
// #include <drivers/ipc_notify.h>
// #include <drivers/ipc_notify/v0/ipc_notify_v0.h>

// /* this function is called within IpcNotify_init, this function returns core specific IPC config */
// void IpcNotify_getConfig(IpcNotify_InterruptConfig **interruptConfig, uint32_t *interruptConfigNum)
// {
//     /* extern globals that are specific to this core */
//     extern IpcNotify_InterruptConfig gIpcNotifyInterruptConfig_r5fss0_0[];
//     extern uint32_t gIpcNotifyInterruptConfigNum_r5fss0_0;

//     *interruptConfig = &gIpcNotifyInterruptConfig_r5fss0_0[0];
//     *interruptConfigNum = gIpcNotifyInterruptConfigNum_r5fss0_0;
// }

// /*
//  * IPC RP Message
//  */
// #include <drivers/ipc_rpmsg.h>

/* Number of CPUs that are enabled for IPC RPMessage */
#define IPC_RPMESSAGE_NUM_CORES           (5U)
/* Number of VRINGs for the numner of CPUs that are enabled for IPC */
#define IPC_RPMESSAGE_NUM_VRINGS          (IPC_RPMESSAGE_NUM_CORES*(IPC_RPMESSAGE_NUM_CORES-1))
/* Number of a buffers in a VRING, i.e depth of VRING queue */
#define IPC_RPMESSAGE_NUM_VRING_BUF       (8U)
/* Max size of a buffer in a VRING */
#define IPC_RPMESSAGE_MAX_VRING_BUF_SIZE  (128U)
/* Size of each VRING is
 *     number of buffers x ( size of each buffer + space for data structures of one buffer (32B) )
 */
#define IPC_RPMESSAGE_VRING_SIZE          RPMESSAGE_VRING_SIZE(IPC_RPMESSAGE_NUM_VRING_BUF, IPC_RPMESSAGE_MAX_VRING_BUF_SIZE)

/* VRING base address, all VRINGs are put one after other in the below region.
 *
 * IMPORTANT: Make sure of below,
 * - The section defined below should be placed at the exact same location in memory for all the CPUs
 * - The memory should be marked as non-cached for all the CPUs
 * - The section should be marked as NOLOAD in all the CPUs linker command file
 */
/* In this case gRPMessageVringMem size is 26240 bytes */
// uint8_t gRPMessageVringMem[IPC_RPMESSAGE_NUM_VRINGS][IPC_RPMESSAGE_VRING_SIZE] __attribute__((aligned(128), section(".bss.ipc_vring_mem")));


// /* Buffer used for trace, address and size of this buffer is put in the resource table so that Linux can read it */
extern char gDebugMemLog[];

// const RPMessage_ResourceTable gRPMessage_linuxResourceTable __attribute__ ((section (".resource_table"), aligned (4096))) =
// {
//     {
//         1U,         /* we're the first version that implements this */
//         2U,         /* number of entries, MUST be 2 */
//         { 0U, 0U, } /* reserved, must be zero */
//     },
//     /* offsets to the entries */
//     {
//         offsetof(RPMessage_ResourceTable, vdev),
//         offsetof(RPMessage_ResourceTable, trace),
//     },
//     /* vdev entry */
//     {
//         RPMESSAGE_RSC_TYPE_VDEV, RPMESSAGE_RSC_VIRTIO_ID_RPMSG,
//         0U, 1U, 0U, 0U, 0U, 2U, { 0U, 0U },
//     },
//     /* the two vrings */
//     { RPMESSAGE_RSC_VRING_ADDR_ANY, 4096U, 256U, 1U, 0U },
//     { RPMESSAGE_RSC_VRING_ADDR_ANY, 4096U, 256U, 2U, 0U },
//     {
//         (RPMESSAGE_RSC_TRACE_INTS_VER0 | RPMESSAGE_RSC_TYPE_TRACE),
//         (uint32_t)gDebugMemLog, DebugP_MEM_LOG_SIZE,
//         0, "trace:r5fss0_0",
//     },
// };



/*
 * PCIe
 */

/* Extern variable declarations */
extern uint32_t dst_buf[];

Pcie_MsiIsrCtrl gPcieMsiIsrCtrlConfigPcie0;
uint8_t gPcieMsiRingMemConfigPcie0[128] __attribute__((aligned(128)));

Pcie_MsiIsrCtrl gPcieMsiIsrCtrlConfigPcie1;
uint8_t gPcieMsiRingMemConfigPcie1[128] __attribute__((aligned(128)));


Pcie_MsixIsrCtrl gPcieMsixIsrCtrlConfigPcie0;
uint8_t gPcieMsixRingMemConfigPcie0[128] __attribute__((aligned(128)));
Pcie_MsixTbl gPcieMsixTblConfigPcie0 __attribute__((aligned(128)));

Pcie_MsixIsrCtrl gPcieMsixIsrCtrlConfigPcie1;
uint8_t gPcieMsixRingMemConfigPcie1[128] __attribute__((aligned(128)));
Pcie_MsixTbl gPcieMsixTblConfigPcie1 __attribute__((aligned(128)));

#if EP_MODE
/* Outbound region settings */
Pcie_ObAtuCfg obAtuConfigPcie0[] =
{
    {
        .regionIndex = 0,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x68000000UL + 0x01000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = 0x90000000,
        .upperTargetAddr = 0x0,
    },
    {
        .regionIndex = 1,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x68000000UL + 0x02000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 65535,
        .lowerTargetAddr = 0x2000000,
        .upperTargetAddr = 0x0,
    },
};

Pcie_ObAtuCfg obAtuConfigPcie1[] =
{
    {
        .regionIndex = 0,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x68000000UL + 0x01000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = 0x90000000,
        .upperTargetAddr = 0x0,
    },
    {
        .regionIndex = 1,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x68000000UL + 0x02000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 65535,
        .lowerTargetAddr = 0x2000000,
        .upperTargetAddr = 0x0,
    },
};

/* Inbound region settings */
Pcie_IbAtuCfg ibAtuConfigPcie0[] =
{
    {
        .regionIndex = 0,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x70000000,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = (uint32_t)dst_buf,
        .upperTargetAddr = 0x0,
        .barAperture = PCIE_EPBARA_4K,
        .barCfg = PCIE_BARC_32B_MEM_BAR_NON_PREFETCH,
    },
};

Pcie_IbAtuCfg ibAtuConfigPcie1[] =
{
    {
        .regionIndex = 0,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x70000000,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = (uint32_t)dst_buf,
        .upperTargetAddr = 0x0,
        .barAperture = PCIE_EPBARA_4K,
        .barCfg = PCIE_BARC_32B_MEM_BAR_NON_PREFETCH,
    },
};

/* PCIe Driver Attributes */
Pcie_Attrs gPcieAttrs[CONFIG_PCIE_NUM_INSTANCES] =
{
    {
        .deviceNum = 0,
        .operationMode = PCIE_EP_MODE,
        .gen = PCIE_GEN1,
        .numLanes = 1,
        .obAtu = obAtuConfigPcie0,
        .obAtuNum = 2,
        .ibAtu = ibAtuConfigPcie0,
        .ibAtuNum = 1,
        .msiGlobalEventNum = 0,
        .msiRingNum = 0,
        .msiIntNum = 0,
        .msiIrqEnableFlag = 0,
        .msiIsrCtrl = &gPcieMsiIsrCtrlConfigPcie0,
        .msiRingMem = &gPcieMsiRingMemConfigPcie0[0],

        .msixGlobalEventNum = 0,
        .msixRingNum = 0,
        .msixIntNum = 0,
        .msixIrqEnableFlag = 0,
        .epMsixTbl = &gPcieMsixTblConfigPcie0,
        .msixIsrCtrl = &gPcieMsixIsrCtrlConfigPcie0,
        .msixRingMem = &gPcieMsixRingMemConfigPcie0[0],
    },
    {
        .deviceNum = 1,
        .operationMode = PCIE_EP_MODE,
        .gen = PCIE_GEN1,
        .numLanes = 1,
        .obAtu = obAtuConfigPcie1,
        .obAtuNum = 2,
        .ibAtu = ibAtuConfigPcie1,
        .ibAtuNum = 1,
        .msiGlobalEventNum = 0,
        .msiRingNum = 0,
        .msiIntNum = 0,
        .msiIrqEnableFlag = 0,
        .msiIsrCtrl = &gPcieMsiIsrCtrlConfigPcie1,
        .msiRingMem = &gPcieMsiRingMemConfigPcie1[0],

        .msixGlobalEventNum = 0,
        .msixRingNum = 0,
        .msixIntNum = 0,
        .msixIrqEnableFlag = 0,
        .epMsixTbl = &gPcieMsixTblConfigPcie1,
        .msixIsrCtrl = &gPcieMsixIsrCtrlConfigPcie1,
        .msixRingMem = &gPcieMsixRingMemConfigPcie1[0],
    },
};
#elif RC_MODE
/* Outbound region settings */
Pcie_ObAtuCfg obAtuConfigPcie0[] =
{
    {
        .regionIndex = 1,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x68000000UL + 0x01000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = 0x70000000,
        .upperTargetAddr = 0x0,
    },
};

Pcie_ObAtuCfg obAtuConfigPcie1[] =
{
    {
        .regionIndex = 1,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x68000000UL + 0x01000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = 0x70000000,
        .upperTargetAddr = 0x0,
    },
};

/* Inbound region settings */
Pcie_IbAtuCfg ibAtuConfigPcie0[] =
{
    {
        .regionIndex = 0,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x90000000,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = (uint32_t)dst_buf,
        .upperTargetAddr = 0x0,
        .barAperture = PCIE_RCBARA_4K,
        .barCfg = PCIE_BARC_32B_MEM_BAR_NON_PREFETCH,
    },
    {
        .regionIndex = 1,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x2000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 255,
        .lowerTargetAddr = 0x4E0143FCU,
        .upperTargetAddr = 0x0,
        .barAperture = PCIE_RCBARA_4K,
        .barCfg = PCIE_BARC_32B_MEM_BAR_NON_PREFETCH,
    },
};

Pcie_IbAtuCfg ibAtuConfigPcie1[] =
{
    {
        .regionIndex = 0,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x90000000,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 4095,
        .lowerTargetAddr = (uint32_t)dst_buf,
        .upperTargetAddr = 0x0,
        .barAperture = PCIE_RCBARA_4K,
        .barCfg = PCIE_BARC_32B_MEM_BAR_NON_PREFETCH,
    },
    {
        .regionIndex = 1,
        .tlpType = PCIE_TLP_TYPE_MEM,
        .lowerBaseAddr = 0x2000000U,
        .upperBaseAddr = 0x0,
        .regionWindowSize = 255,
        .lowerTargetAddr = 0x4E0143FCU,
        .upperTargetAddr = 0x0,
        .barAperture = PCIE_RCBARA_4K,
        .barCfg = PCIE_BARC_32B_MEM_BAR_NON_PREFETCH,
    },
};

/* PCIe Driver Attributes */
Pcie_Attrs gPcieAttrs[CONFIG_PCIE_NUM_INSTANCES] =
{
    {
        .deviceNum = 0,
        .operationMode = PCIE_RC_MODE,
        .gen = PCIE_GEN1,
        .numLanes = 1,
        .obAtu = obAtuConfigPcie0,
        .obAtuNum = 1,
        .ibAtu = ibAtuConfigPcie0,
        .ibAtuNum = 2,
        .msiGlobalEventNum = 0,
        .msiRingNum = 0,
        .msiIntNum = 0,
        .msiIrqEnableFlag = 0,
        .msiIsrCtrl = &gPcieMsiIsrCtrlConfigPcie0,
        .msiRingMem = &gPcieMsiRingMemConfigPcie0[0],

        .msixGlobalEventNum = 0,
        .msixRingNum = 0,
        .msixIntNum = 0,
        .msixIrqEnableFlag = 0,
        .epMsixTbl = &gPcieMsixTblConfigPcie0,
        .msixIsrCtrl = &gPcieMsixIsrCtrlConfigPcie0,
        .msixRingMem = &gPcieMsixRingMemConfigPcie0[0],
    },
    {
        .deviceNum = 1,
        .operationMode = PCIE_RC_MODE,
        .gen = PCIE_GEN1,
        .numLanes = 1,
        .obAtu = obAtuConfigPcie1,
        .obAtuNum = 1,
        .ibAtu = ibAtuConfigPcie1,
        .ibAtuNum = 2,
        .msiGlobalEventNum = 0,
        .msiRingNum = 0,
        .msiIntNum = 0,
        .msiIrqEnableFlag = 0,
        .msiIsrCtrl = &gPcieMsiIsrCtrlConfigPcie1,
        .msiRingMem = &gPcieMsiRingMemConfigPcie1[0],

        .msixGlobalEventNum = 0,
        .msixRingNum = 0,
        .msixIntNum = 0,
        .msixIrqEnableFlag = 0,
        .epMsixTbl = &gPcieMsixTblConfigPcie1,
        .msixIsrCtrl = &gPcieMsixIsrCtrlConfigPcie1,
        .msixRingMem = &gPcieMsixRingMemConfigPcie1[0],
    }
};
#endif
/* Pcie objects - initialized by the driver */
static Pcie_Object gPcieObjects[CONFIG_PCIE_NUM_INSTANCES];

/* Pcie driver configuration */
Pcie_Config gPcieConfig[CONFIG_PCIE_NUM_INSTANCES] =
{
    {
        &gPcieObjects[CONFIG_PCIE0],
        &gPcieAttrs[CONFIG_PCIE0],
    },
    {
        &gPcieObjects[CONFIG_PCIE1],
        &gPcieAttrs[CONFIG_PCIE1],
    }
};

uint32_t gPcieConfigNum = CONFIG_PCIE_NUM_INSTANCES;

void Drivers_pcieInit(void)
{
    DebugP_log("%s %d\n", __func__, __LINE__);
    Pcie_init();
}

void Pinmux_init(void);
void PowerClock_init(void);
void PowerClock_deinit(void);

/*
 * Common Functions
 */
void System_init(void)
{
//     /* DPL init sets up address transalation unit, on some CPUs this is needed
//      * to access SCICLIENT services, hence this needs to happen first
//      */
//     Dpl_init();
    /* We should do sciclient init before we enable power and clock to the peripherals */
    /* SCICLIENT init */
    // {
    //     int32_t retVal = SystemP_SUCCESS;

    //     retVal = Sciclient_init(CSL_CORE_ID_R5FSS0_0);
    //     DebugP_assert(SystemP_SUCCESS == retVal);
    // }

    
    /* initialize PMU */
    // CycleCounterP_init(SOC_getSelfCpuClk());


//     PowerClock_init();
//     /* Now we can do pinmux */
//     Pinmux_init();
//     /* finally we initialize all peripheral drivers */
//     /* IPC Notify */
//     {
//         IpcNotify_Params notifyParams;
//         int32_t status;

//         /* initialize parameters to default */
//         IpcNotify_Params_init(&notifyParams);

//         /* specify the core on which this API is called */
//         notifyParams.selfCoreId = CSL_CORE_ID_R5FSS0_0;

//         /* list the cores that will do IPC Notify with this core
//         * Make sure to NOT list 'self' core in the list below
//         */
//         notifyParams.numCores = 5;
//         notifyParams.coreIdList[0] = CSL_CORE_ID_R5FSS0_1;
//         notifyParams.coreIdList[1] = CSL_CORE_ID_R5FSS1_0;
//         notifyParams.coreIdList[2] = CSL_CORE_ID_R5FSS1_1;
//         notifyParams.coreIdList[3] = CSL_CORE_ID_M4FSS0_0;
//         notifyParams.coreIdList[4] = CSL_CORE_ID_A53SS0_0;
//         notifyParams.linuxCoreId = CSL_CORE_ID_A53SS0_0;

//         /* initialize the IPC Notify module */
//         status = IpcNotify_init(&notifyParams);
//         DebugP_assert(status==SystemP_SUCCESS);

//     }
//     /* IPC RPMessage */
//     {
//         RPMessage_Params rpmsgParams;
//         int32_t status;

//         /* initialize parameters to default */
//         RPMessage_Params_init(&rpmsgParams);

//         /* VRING mapping from source core to destination core, '-1' means NO VRING,
//             r5fss0_0 => {"r5fss0_0":-1,"r5fss0_1":0,"r5fss1_0":1,"r5fss1_1":2,"m4fss0_0":3}
//             r5fss0_1 => {"r5fss0_0":4,"r5fss0_1":-1,"r5fss1_0":5,"r5fss1_1":6,"m4fss0_0":7}
//             r5fss1_0 => {"r5fss0_0":8,"r5fss0_1":9,"r5fss1_0":-1,"r5fss1_1":10,"m4fss0_0":11}
//             r5fss1_1 => {"r5fss0_0":12,"r5fss0_1":13,"r5fss1_0":14,"r5fss1_1":-1,"m4fss0_0":15}
//             m4fss0_0 => {"r5fss0_0":16,"r5fss0_1":17,"r5fss1_0":18,"r5fss1_1":19,"m4fss0_0":-1}
//          */
//         /* TX VRINGs */
//         rpmsgParams.vringTxBaseAddr[CSL_CORE_ID_R5FSS0_1] = (uintptr_t)gRPMessageVringMem[0];
//         rpmsgParams.vringTxBaseAddr[CSL_CORE_ID_R5FSS1_0] = (uintptr_t)gRPMessageVringMem[1];
//         rpmsgParams.vringTxBaseAddr[CSL_CORE_ID_R5FSS1_1] = (uintptr_t)gRPMessageVringMem[2];
//         rpmsgParams.vringTxBaseAddr[CSL_CORE_ID_M4FSS0_0] = (uintptr_t)gRPMessageVringMem[3];
//         /* RX VRINGs */
//         rpmsgParams.vringRxBaseAddr[CSL_CORE_ID_R5FSS0_1] = (uintptr_t)gRPMessageVringMem[4];
//         rpmsgParams.vringRxBaseAddr[CSL_CORE_ID_R5FSS1_0] = (uintptr_t)gRPMessageVringMem[8];
//         rpmsgParams.vringRxBaseAddr[CSL_CORE_ID_R5FSS1_1] = (uintptr_t)gRPMessageVringMem[12];
//         rpmsgParams.vringRxBaseAddr[CSL_CORE_ID_M4FSS0_0] = (uintptr_t)gRPMessageVringMem[16];
//         /* Other VRING properties */
//         rpmsgParams.vringSize = IPC_RPMESSAGE_VRING_SIZE;
//         rpmsgParams.vringNumBuf = IPC_RPMESSAGE_NUM_VRING_BUF;
//         rpmsgParams.vringMsgSize = IPC_RPMESSAGE_MAX_VRING_BUF_SIZE;
//         rpmsgParams.linuxResourceTable = &gRPMessage_linuxResourceTable;
//         rpmsgParams.linuxCoreId = CSL_CORE_ID_A53SS0_0;

//         /* initialize the IPC RP Message module */
//         status = RPMessage_init(&rpmsgParams);
//         DebugP_assert(status==SystemP_SUCCESS);
//     }
    DebugP_log("%s %d\n", __func__, __LINE__);
    Drivers_pcieInit();
}

void System_deinit(void)
{
    // RPMessage_deInit();
    // IpcNotify_deInit();

    // PowerClock_deinit();
    /* SCICLIENT deinit */
    {
        int32_t         retVal = SystemP_SUCCESS;

        retVal = Sciclient_deinit();
        DebugP_assert(SystemP_SUCCESS == retVal);
    }
    // Dpl_deinit();
}
