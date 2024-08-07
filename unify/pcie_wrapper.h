
#ifndef PCIE_WRAPPER_H
#define PCIE_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <ti/drv/ipc/examples/common/src/ipc_setup.h>

#define DebugP_log  App_printf

/**
 * \name Debug log APIs
 * @{
 */

/**
 * \brief Function to log a string to the enabled console, for error zone.
 *
 * This API should not be called within ISR context.
 *
 * \param format [in] String to log
 */
#define DebugP_logError(format, ...)     \
    do { \
        DebugP_log("ERROR: %s:%d: " format, __FUNCTION__, __LINE__, ##__VA_ARGS__); \
    } while(0)

/**
 * \brief Function to log a string to the enabled console, for warning zone.
 *
 * This API should not be called within ISR context.
 *
 * \param format [in] String to log
 */
#define DebugP_logWarn(format, ...)     \
    do { \
        DebugP_log("WARNING: %s:%d: " format, __FUNCTION__, __LINE__, ##__VA_ARGS__); \
    } while(0)

/**
 * \brief Function to log a string to the enabled console, for info zone.
 *
 * This API should not be called within ISR context.
 *
 * \param format [in] String to log
 */
#define DebugP_logInfo(format, ...)     \
    do { \
        DebugP_log("INFO: %s:%d: " format, __FUNCTION__, __LINE__, ##__VA_ARGS__); \
    } while(0)

 /** @} */

// void ClockP_usleep(int time){};

#ifdef __cplusplus
}
#endif

#endif  /* #ifndef PCIE_WRAPPER_H */