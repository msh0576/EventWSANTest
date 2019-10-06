/*
 * @author IPP HURRAY http://www.hurray.isep.ipp.pt/art-wise
 * @author open-zb http://www.open-zb.net
 * @author Andre Cunha
 */
 
#ifndef __NWK_ENUMERATIONS__
#define __NWK_ENUMERATIONS__
 
//NWK layer status values 
//page 243
enum { 
	NWK_SUCCESS = 0x00,
    NWK_INVALID_PARAMETER = 0xc1,
    NWK_INVALID_REQUEST = 0xc2,
	NWK_NOT_PERMITTED = 0xc3,
	NWK_STARTUP_FAILURE = 0xc4,
	NWK_ALREADY_PRESENT = 0xc5,
	NWK_SYNC_FAILURE = 0xc6,
	NWK_TABLE_FULL = 0xc7,
	NWK_UNKNOWN_DEVICE = 0xc8,
	NWK_UNSUPPORTED_ATTRIBUTE = 0xc9,
	NWK_NO_NETWORKS = 0xca,
	NWK_LEAVE_UNCONFIRMED = 0xcb,
	NWK_MAX_FRM_CNTR = 0xcc,
	NWK_NO_KEY = 0xcd,
	NWK_BAD_CCM_OUTPUT = 0xce
    };

//NWK layer device types
//page 342
enum {
	COORDINATOR = 0x00,
	ROUTER =0x01,
	END_DEVICE = 0x02
	};


//NWK layer Relationship
//page 342
enum {
	NEIGHBOR_IS_PARENT = 0x00,
	NEIGHBOR_IS_CHILD = 0x01,
	NEIGHBOR_IS_SIBLING = 0x02,
	NEIGHBOR_IS_NON = 0x03,
	NEIGHBOR_IS_PREVIOUS_CHILD = 0x04,
	};
	

//NWK layer PIB attributs ennumerations
//PAG 317
enum{
	NWKSEQUENCENUMBER = 0x81,
	NWKPASSIVEACKTIMEOUT = 0x82,
	NWKMAXBROADCASTRETRIES = 0x83,
	NWKMAXCHILDREN = 0x84,
	NWKMAXDEPTH = 0x85,
	NWKMAXROUTERS = 0x86,
	//NWKNEIGHBORTABLE = 0x87
	NWKMETWORKBROADCASTDELIVERYTIME = 0x88,
	NWKREPORTCONSTANTCOST = 0x89,
	NWKROUTEDISCOVERYRETRIESPERMITED = 0x8a,
	//NWKROUTETABLE
	NWKSYMLINK = 0x8e,
	NWKCAPABILITYINFORMATION = 0x8f,
	NWKUSETREEADDRALLOC = 0x90,
	NWKUSETREEROUTING = 0x91,
	NWKNEXTADDRESS = 0x92,
	NWKAVAILABLEADDRESSES = 0x93,
	NWKADDRESSINCREMENT = 0x94,
	NWKTRANSACTIONPERSISTENCETIME = 0x95
};

#endif
