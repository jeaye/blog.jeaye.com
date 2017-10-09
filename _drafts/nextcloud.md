### hmm
* Bring in `/dev/urandom`
* Redis?
* Disable previews?
* Opcache
* Cron
* Network access

## Current issues
* Cron not running

### Why is google being accessed?
```text
	GuzzleHttp\Exception\ConnectException: cURL error 6: Couldn't resolve host 'www.google.com'
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/guzzle/src/RequestFsm.php - line 103: GuzzleHttp\Exception\RequestException wrapException(Object(GuzzleHttp\Message\Request), Object(GuzzleHttp\Ring\Exception\ConnectException))
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/guzzle/src/RequestFsm.php - line 132: GuzzleHttp\RequestFsm->__invoke(Object(GuzzleHttp\Transaction))
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/react/promise/src/FulfilledPromise.php - line 25: GuzzleHttp\RequestFsm->GuzzleHttp\{closure}(Array)
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/ringphp/src/Future/CompletedFutureValue.php - line 55: React\Promise\FulfilledPromise->then(Object(Closure), NULL, NULL)
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/guzzle/src/Message/FutureResponse.php - line 43: GuzzleHttp\Ring\Future\CompletedFutureValue->then(Object(Closure), NULL, NULL)
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/guzzle/src/RequestFsm.php - line 134: GuzzleHttp\Message\FutureResponse proxy(Object(GuzzleHttp\Ring\Future\CompletedFutureArray), Object(Closure))
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/guzzle/src/Client.php - line 165: GuzzleHttp\RequestFsm->__invoke(Object(GuzzleHttp\Transaction))
/etc/user/http/cloud.pastespace.org/nextcloud/3rdparty/guzzlehttp/guzzle/src/Client.php - line 125: GuzzleHttp\Client->send(Object(GuzzleHttp\Message\Request))
/etc/user/http/cloud.pastespace.org/nextcloud/lib/private/Http/Client/Client.php - line 138: GuzzleHttp\Client->get('http //www.goog...', Array)
/etc/user/http/cloud.pastespace.org/nextcloud/settings/Controller/CheckSetupController.php - line 125: OC\Http\Client\Client->get('http //www.goog...')
/etc/user/http/cloud.pastespace.org/nextcloud/settings/Controller/CheckSetupController.php - line 108: OC\Settings\Controller\CheckSetupController->isSiteReachable('www.google.com')
/etc/user/http/cloud.pastespace.org/nextcloud/settings/Controller/CheckSetupController.php - line 414: OC\Settings\Controller\CheckSetupController->isInternetConnectionWorking()
[internal function] OC\Settings\Controller\CheckSetupController->check()
/etc/user/http/cloud.pastespace.org/nextcloud/lib/private/AppFramework/Http/Dispatcher.php - line 160: call_user_func_array(Array, Array)
/etc/user/http/cloud.pastespace.org/nextcloud/lib/private/AppFramework/Http/Dispatcher.php - line 90: OC\AppFramework\Http\Dispatcher->executeController(Object(OC\Settings\Controller\CheckSetupController), 'check')
/etc/user/http/cloud.pastespace.org/nextcloud/lib/private/AppFramework/App.php - line 114: OC\AppFramework\Http\Dispatcher->dispatch(Object(OC\Settings\Controller\CheckSetupController), 'check')
/etc/user/http/cloud.pastespace.org/nextcloud/lib/private/AppFramework/Routing/RouteActionHandler.php - line 47: OC\AppFramework\App main('OC\\Settings\\Con...', 'check', Object(OC\AppFramework\DependencyInjection\DIContainer), Array)
[internal function] OC\AppFramework\Routing\RouteActionHandler->__invoke(Array)
/etc/user/http/cloud.pastespace.org/nextcloud/lib/private/Route/Router.php - line 299: call_user_func(Object(OC\AppFramework\Routing\RouteActionHandler), Array)
/etc/user/http/cloud.pastespace.org/nextcloud/lib/base.php - line 1004: OC\Route\Router->match('/settings/ajax/...')
/etc/user/http/cloud.pastespace.org/nextcloud/index.php - line 48: OC handleRequest()
{main}
```
