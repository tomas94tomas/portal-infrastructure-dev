# Portal infrastructure (in kubernetes)

Defines service definitions that are used to run breach.gg on cloud

<a href="https://github.com/BreachGG/portal-infrastructure/compare/dev...master"><kbd> <br> Create PR (Master -> Dev) <br> </kbd></a> <a href="https://github.com/BreachGG/portal-infrastructure/compare/master...dev"><kbd> <br> Create PR (Dev -> Master) <br> </kbd></a>

<dl>
<dt>How to first time setup?</dt>
<dd><ol>
    <li>Checkout this repo</li>
    <li>Go to:
   Azure portal -> (selected kubernetes service) -> Connect (button)</li>
    <li>Execute locally there shown commands</li>
    <li>Copy .env.dist -> .env (locally)</li>
    <li>Fill .env values</li>
    <li>Run `./configure.sh`</li>
</ol></dd>  
<dt>Can't execute kubectl command on azure?</dt>
<dd>Do not use kubectl from minikube or similar tool.</dd>
<dt>How to access Traefik admin?</dt>
<dd>In linked KeyVault you can find <code>traefik-auth-user</code> and <code>traefik-auth-password</code> secrets. These are used for authentication into Traefik dashboard.
<br /><br />
Dashboard is accessible typing <code>http://<i>{SERVER_IP}</i>/dashboard/</code> in your browser. Where <code><i>{SERVER_IP}</i></code> is IP of server environment that you need to access.
</dd>
<dt>How to add new/change environment variable or remove old one?</dt>
<dd>
If it needs value to be fetched from KeyVault - <code>helmfile.d/values/services/breachgg.yaml.gotmpl</code>.<br />
If is static and shared between environments - <code>helmfile.d/values/environments/global.yaml</code><br />
If is static but not shared between environments - <code>helmfile.d/values/environments/<i>ENVIRONMENT</i>.yaml</code> where <code><i>ENVIRONMENT</i></code> is name in lowercase of environmenmts<br />
<br />
In all cases these new environments variables should be defined as <code>env:</code> subkeys.
</dd>
<dt>How to define new breach.gg service or change old?</dt>
<dd>Edit or create new yaml/go based templates in <code>./charts/breachgg/templates/</code>.<br /><br />
All service definitions that has public ports must have <code>*-service.yaml</code> and <code>*-deployment.yaml</code>. If service doesn't need port <code>*-deployment.yaml</code> only needed. <code>*-ingress</code> is needed for configuring https certificates and URLs & paths.</dd>
<dt>Problem: can't access secrets with configured user</dt>
<dd>Run locally these commands: <br />
<code>./tools/kube/bind-role.sh cert-manager-controller-certificates USER_OBJECT_ID cert-manager</code><br />
<code>./tools/kube/bind-clusterrole.sh admin USER_OBJECT_ID</code><br />
<code>./tools/kube/bind-clusterrole.sh cluster-admin USER_OBJECT_ID</code></dd>
<dt>Problem: I changed KeyVault secret but value doesn't updated</dt>
<dd>You need to redeploy this repo from needed branch. Sadly secrets for now synced manually.</dd>  
</dl>
