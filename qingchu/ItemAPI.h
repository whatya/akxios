//
//  ItemAPI.h
//  qingchu
//
//  Created by ZhuXiaoyan on 16/3/10.
//  Copyright © 2016年 whtriples. All rights reserved.
//

#ifndef ItemAPI_h
#define ItemAPI_h

//商品相关
#define ItemsList       @"chunhui/m/product@getAllProduct.do"
#define ItemDesc        @"chunhui/m/product@getProductInfo.do"
#define ClassesList     @"chunhui/m/product@getClassification.do"

//地址相关
#define AddressFetch    @"chunhui/m/user@getMyAddress.do"
#define EditAddress     @"chunhui/m/user@setMyAddress.do"

//订单相关
#define SubmitOrder     @"chunhui/m/order@submitOrder.do"
#define OrderList       @"chunhui/m/order@getAllOrder.do"
#define OrderDetail     @"chunhui/m/order@getOrderInfo.do"

#endif /* ItemAPI_h */
