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

#ifndef TI_DRIVERS_CONFIG_H_
#define TI_DRIVERS_CONFIG_H_

#include <stdint.h>
#include <ti/csl/soc.h>
// #include "ti_dpl_config.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Common Functions
 */
void System_init(void);
void System_deinit(void);

/*
 * IPC Notify
 */
// #include <drivers/ipc_notify.h>

/*
 * IPC RPMessage
 */
// #include <drivers/ipc_rpmsg.h>

/*
 * PCIe
 */
#include <drivers/pcie.h>

/* PCIe Instance Macros */
#define CONFIG_PCIE0 (0U)
#define CONFIG_PCIE1 (1U)
#define CONFIG_PCIE_NUM_INSTANCES (2U)

#if EP_MODE
#define CONFIG_PCIE0_IB_REGION0 (0U)

#define CONFIG_PCIE0_OB_REGION0 (0U)
#define CONFIG_PCIE0_OB_REGION1 (1U)

#define CONFIG_PCIE0_OB_REGION0_LOWER (0x68000000UL + 0x01000000U)
#define CONFIG_PCIE0_OB_REGION0_UPPER (0x0)
#define CONFIG_PCIE0_OB_REGION1_LOWER (0x68000000UL + 0x02000000U)
#define CONFIG_PCIE0_OB_REGION1_UPPER (0x0)

#define CONFIG_PCIE1_IB_REGION0 (0U)

#define CONFIG_PCIE1_OB_REGION0 (0U)
#define CONFIG_PCIE1_OB_REGION1 (1U)

#define CONFIG_PCIE1_OB_REGION0_LOWER (0x68000000UL + 0x01000000U)
#define CONFIG_PCIE1_OB_REGION0_UPPER (0x0)
#define CONFIG_PCIE1_OB_REGION1_LOWER (0x68000000UL + 0x02000000U)
#define CONFIG_PCIE1_OB_REGION1_UPPER (0x0)

#elif RC_MODE
#define CONFIG_PCIE0_IB_REGION0 (0U)
#define CONFIG_PCIE0_IB_REGION1 (1U)

#define CONFIG_PCIE0_OB_REGION0 (0U)

#define CONFIG_PCIE0_OB_REGION0_LOWER (0x68000000UL + 0x01000000U)
#define CONFIG_PCIE0_OB_REGION0_UPPER (0x0)

#define CONFIG_PCIE1_IB_REGION0 (0U)
#define CONFIG_PCIE1_IB_REGION1 (1U)

#define CONFIG_PCIE1_OB_REGION0 (0U)

#define CONFIG_PCIE1_OB_REGION0_LOWER (0x68000000UL + 0x01000000U)
#define CONFIG_PCIE1_OB_REGION0_UPPER (0x0)

#endif

#include <ti/csl/soc.h>
#include <kernel/dpl/CycleCounterP.h>

#define CSL_CORE_ID_R5FSS0_0         (1U)
#define CSL_CORE_ID_R5FSS0_1         (2U)

#ifdef __cplusplus
}
#endif

#endif /* TI_DRIVERS_CONFIG_H_ */
