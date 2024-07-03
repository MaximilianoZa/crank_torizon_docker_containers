/*
 * Copyright 2022, Crank Software Inc. All Rights Reserved.
 *
 * For more information email info@cranksoftware.com.
 */
#ifndef SBIO_WRAPPER_H
#define SBIO_WRAPPER_H

#include <gre/greio.h>

#ifdef _WIN32
#define DLLExport __declspec( dllexport )
#else 
#define DLLExport
#endif


#ifdef __cplusplus
extern "C"{
#endif


/******
*  Setup functions to make using SBIO easier
******/

/**
 * Opaque handle for IO operations.
 */
typedef struct _sbio_channel_handle_ sbio_channel_handle_t;

/**
 * Typedef for a callback function that will be called when receiving an event
 */
typedef void (*sbio_event_callback_t)(const char *event_name, char *event_format, void *event_data, int event_data_size, void *user_data);

/**
 * Opens a Storyboard IO channel for sending events on.
 *
 * @param channel_name The name of the channel to open for sending
 * @param flag Additional flags, other than GRE_IO_TYPE_WRONLY, to open the channel with
 * @param sbio_channel_handle_t A pointer to the storage location for an sbio_channel_handle_t structure used for storing channel information
 * @return 0 on success and non-zero on failure
 */
DLLExport int sbio_create_send_channel(const char *channel_name, int flags, sbio_channel_handle_t **handle);

/**
 * Opens a Storyboard IO channel for receiving events on.
 *
 * @param channel_name The name of the channel to open for receiving
 * @param flag Additional flash, other than GRE_IO_TYPE_RDONLY, to open the channel with
 * @param sbio_channel_handle_t A pointer to the storage location for an sbio_channel_handle_t structure used for storing channel information
 * @return 0 on success and non-zero on failure
 */
DLLExport int sbio_create_receive_channel(const char *channel_name, int flags, sbio_channel_handle_t **handle);

/**
 * Sends an event on a channel that has been opened for sending.  
 *  
 * @param sbio_channel_handle_t A pointer to an sbio_channel_handle_t for storing channel information
 * @param event_name The name of the event to send
 * @param event_fmt The format of the event to send
 * @param event_data The event data that should be sent
 * @param event_data_size The size of the data to send.
 * @return 0 on success and non-zero on failure
 */
DLLExport int sbio_send_event(sbio_channel_handle_t *handle, const char *event_name, const char *event_fmt, void *event_data, int event_data_size);

/**
 * Adds a callback to a receive channel.
 * 
 * The event name can be specified as a pattern.
 * "*"			    -> Any event
 * "event_name"		-> Exact match to 'event_name'
 * "*event_name*"	-> Anything containing 'event_name'	
 *
 * @param handle The receive handle to add the callback to
 * @param event_name The name of the event to listen for, or NULL for all events.
 * @param callback_function The function to call when the event is received
 * @param user_data Data that should be passed to the callback
 * @return 0 on success and non-zero on failure
 */
DLLExport int sbio_add_event_callback(sbio_channel_handle_t *handle, const char *event_name, sbio_event_callback_t callback_function, void *user_data);

/**
 *  Removes a callback from a receive channel
 *
 * @param handle The receive handle to remove the callback from
 * @param callback_funtion The callback function to remove
 * @param user_data The user data that is passed into the callback function to remove
 * @return 0 on success and non-zero on failure
 */
DLLExport int sbio_rem_event_callback(sbio_channel_handle_t *handle, sbio_event_callback_t callback_function, void *user_data);

/**
 * Destroys a Storyboard IO channel.
 *
 * @param sbio_channel_handle_t A pointer to an sbio_channel_handle_t for the channel that should be destroyed
 * @return 0 on success and non-zero on failure
 */
DLLExport int sbio_destroy_channel(sbio_channel_handle_t *handle);

#ifdef __cplusplus
}
#endif

#endif