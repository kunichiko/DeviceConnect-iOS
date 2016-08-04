//
//  DConnectProfile.h
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief プロファイルの基礎機能を提供する。
 @author NTT DOCOMO
 */
#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectRequestMessage.h>
#import <DConnectSDK/DConnectResponseMessage.h>
#import <DConnectSDK/DConnectApiEntity.h>
#import <DConnectSDK/DConnectApiSpec.h>
#import "DConnectProfileSpec.h"

/*!
 @class DConnectProfile
 @brief プロファイルのベースクラス。
 
 このサンプルコードでは、以下のようなURLに対応する。<br>
 GET http://{dConnectドメイン}/gotapi/example/test?serviceId=xxxx
 
 */
@interface DConnectProfile : NSObject

/*!
 @brief プロファイルプロバイダ。(DConnectProfileProvider型のポインタ)
 */
@property (nonatomic, weak) id provider;




/*!
 @brief DConnectProfileProviderオブジェクトを指定して初期化する。
 
 @param[in] provider DConnectProfileProviderインスタンス
 
 @retval DConnectProfileインスタンス。
 */
- (instancetype) initWithProvider: (id) provider;

/*!
 @brief プロファイルに設定されているDevice Connect API実装のリストを返す.
 @retval API実装のリスト(DConnectApiEntityの配列)
 */
- (NSArray *) apis;


/*!
 @brief 指定されたリクエストに対応するDevice Connect API実装を返す.
 @param[in] path リクエストされたAPIのパス
 @param[in] method リクエストされたAPIのメソッド
 @retval 指定されたリクエストに対応するAPI実装を返す. 存在しない場合は<code>null</code>
 */
- (DConnectApiEntity *) findApiWithPath: (NSString *) path method: (DConnectSpecMethod) method;

/*!
 @brief プロファイル名、インターフェース名、アトリビュート名からパスを作成する.
 @param[in] profileName プロファイル名
 @param[in] interfaceName インターフェース名
 @param[in] attributeName アトリビュート名
 @retval パス
 */
- (NSString *) apiPathWithProfile : (NSString *) profileName interfaceName : (NSString *) interfaceName attributeName:(NSString *) attributeName;


/*!
 @brief 本プロファイル実装を提供するサービスを設定する.
 
 @param[in] service サービス
 */
//- (void) setService: (DConnectService *) service;

/*!
 @brief 本プロファイル実装を提供するサービスを取得する.
 
 @retval サービス
 */
//- (DConnectService *) service;


/*!
 @brief Device Connect API 仕様定義リストを設定する.
 @param[in] profileSpec API 仕様定義リスト
 */
- (void) setProfileSpec: (DConnectProfileSpec *) profileSpec;

/**
 * Device Connect API 仕様定義リストを取得する.
 * @return API 仕様定義リスト
 */
- (DConnectProfileSpec *) profileSpec;

/*!
 @brief プロファイル名を取得する。
 
 実装されていない場合には、nilを返却する。
 
 @return プロファイル名
 */
- (NSString *) profileName;

/*!
 @brief プロファイルの表示名を取得する。
 
 実装されていない場合には、nilを返却する。
 @return プロファイルの表示名
 */
- (NSString *) displayName;

/*!
 
 @brief プロファイルの説明文を取得する。
 実装されていない場合には、nilを返却する。
 
 @return プロファイルの説明文
 */
- (NSString *) detail;

/*!
 
 @brief プロファイルの有効期間(分)を取得する。
 実装されていない場合には、180日とする。
 
 @return 有効期間(分)
 */
- (long long) expirePeriod;

/*!
 @brief リクエストを受領し、各メソッドにリクエストを配送する。
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @return responseが処理済みならYES、そうでなければNO。responseの非同期更新がまだ完了していないなどの理由でresponseを返却すべきでない状況ならばNOを返すべき。
 */
- (BOOL) didReceiveRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;

/*!
 
 @brief GETメソッドリクエスト受信時に呼び出される。
 
 この関数でRESTfulのGETメソッドに対応する処理を記述する。
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @return responseが処理済みならYES、そうでなければNO。responseの非同期更新がまだ完了していないなどの理由でresponseを返却すべきでない状況ならばNOを返すべき。
 */
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;

/*!
 @brief POSTメソッドリクエスト受信時に呼び出される。
 
 この関数でRESTfulのPOSTメソッドに対応する処理を記述する。
 
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @return responseが処理済みならYES、そうでなければNO。responseの非同期更新がまだ完了していないなどの理由でresponseを返却すべきでない状況ならばNOを返すべき。
 */
- (BOOL) didReceivePostRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;

/*!
 
 @brief PUTメソッドリクエスト受信時に呼び出される。
 この関数でRESTfulのPUTメソッドに対応する処理を記述する。
 
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @return responseが処理済みならYES、そうでなければNO。responseの非同期更新がまだ完了していないなどの理由でresponseを返却すべきでない状況ならばNOを返すべき。
 */
- (BOOL) didReceivePutRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;

/*!
 @brief DELETEメソッドリクエスト受信時に呼び出される。
 この関数でRESTfulのDELETEメソッドに対応する処理を記述する。
 
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @return responseが処理済みならYES、そうでなければNO。responseの非同期更新がまだ完了していないなどの理由でresponseを返却すべきでない状況ならばNOを返すべき。
 */
- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;


/*!
 @brief GetメソッドのAPIパスと処理を登録する。
 
 @param[in] path APIパス
 @param[in] api このメソッドのリクエストがあったときに実行される処理
 */
- (void) addGetPath:(NSString *)path api:(DConnectApiFunction)api;

/*!
 @brief PostメソッドのAPIパスと処理を登録する。
 
 @param[in] path APIパス
 @param[in] api このメソッドのリクエストがあったときに実行される処理
 */
- (void) addPostPath:(NSString *)path api:(DConnectApiFunction)api;

/*!
 @brief PutメソッドのAPIパスと処理を登録する。
 
 @param[in] path APIパス
 @param[in] api このメソッドのリクエストがあったときに実行される処理
 */
- (void) addPutPath:(NSString *)path api:(DConnectApiFunction)api;

/*!
 @brief DeleteメソッドのAPIパスと処理を登録する。
 
 @param[in] path APIパス
 @param[in] api このメソッドのリクエストがあったときに実行される処理
 */
- (void) addDeletePath:(NSString *)path api:(DConnectApiFunction)api;

/*!
 @brief Device Connect API実装を削除する.
 @param[in] apiEntity 削除するAPI実装
 */
- (void) removeApi: (DConnectApiEntity *) apiEntity;

/*!
 @brief APIが実装済か確認する。
 @param[in] path パス
 @param[in] method メソッド
 @retval YES APIが実装済である
 @retval NO APIが実装済ではない
 */
- (BOOL) hasApi: (NSString *) path method: (DConnectSpecMethod) method;

@end
