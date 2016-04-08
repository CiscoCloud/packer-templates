set -ux

# FIXME
apk add cloud-init e2fsprogs-extra

cat >/etc/conf.d/cloud-init-local <<'EOF'
rc_after="docker"
EOF

# FIXME
sed -i -e '71i\ \ \ \ \ lock_passwd: false' /etc/cloud/cloud.cfg

# FIXME
patch -p0 <<'EOF'
--- /usr/lib/python2.7/site-packages/cloudinit/distros/alpine.py.orig
+++ /usr/lib/python2.7/site-packages/cloudinit/distros/alpine.py
@@ -186,18 +186,22 @@
             util.logexc(LOG, "Failed to create user %s", name)
             raise e
 
+        # Unlock the user
+        LOG.debug("Unlocking user %s", name)
+        try:
+            util.subp(['passwd', '-u', name], logstring=['passwd', '-u', name])
+        except Exception as e:
+            util.logexc(LOG, "Failed to unlock user %s", name)
+            raise e
+
         if 'groups' in kwargs:
             groups = kwargs['groups']
-            if isinstance(groups, six.string_types):
+            if groups and isinstance(groups, str):
                 # Why are these even a single string in the first place?
-                groups = [groups.split(',')]
-            for group in kwargs['groups']:
+                groups = groups.split(',')
+            for group in groups:
                 try:
                     util.subp(['adduser', name, group], logstring=['adduser', name, group])
                 except Exception as e:
                     util.logexc(LOG, "Failed to add user %s to group %s", name, group)
                     raise e
-
-    def lock_passwd(self, name):
-        # Already locked
-        pass
EOF

for i in cloud-config cloud-final cloud-init cloud-init-local ; do
  rc-update add $i
done
