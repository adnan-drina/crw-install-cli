FROM fedora:32

USER root

ENV MANDREL_VERSION="20.2.0.0.Final" \
    MAVEN_VERSION="3.6.3" \
    OC_VERSION="4.6" \
    KN_VERSION="0.17.3" \
    TKN_VERSION="0.13.1" \
    ODO_VERSION="v2.0.3" \
    KAM_VERSION="v0.0.16" \
    HOME="/home/developer"

# Install prerequisites for Mandrel, podman and wget
RUN dnf install -y glibc-devel zlib-devel gcc gcc-c++ libffi-devel \
    podman \
    wget curl git

# Install Mandrel
RUN wget -O /tmp/mandrel.tar.gz https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}/mandrel-java11-linux-amd64-${MANDREL_VERSION}.tar.gz \
    && tar -xvzf /tmp/mandrel.tar.gz && rm -rf /tmp/mandrel.tar.gz
ENV JAVA_HOME="${pwd}/mandrel-java11-${MANDREL_VERSION}"
ENV GRAALVM_HOME="${JAVA_HOME}"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
RUN echo $(java -version)

# Install Maven
RUN wget -O /tmp/maven.tar.gz https://www-us.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xvzf /tmp/maven.tar.gz && rm -rf /tmp/maven.tar.gz
ENV M2_HOME="/apache-maven-${MAVEN_VERSION}"
ENV PATH="${M2_HOME}/bin:${PATH}"
RUN echo $(mvn -v)

# Install OpenShift cli
RUN wget -O /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz \
    && cd /usr/bin && tar -xvzf /tmp/oc.tar.gz && chmod a+x /usr/bin/oc && rm -f /tmp/oc.tar.gz
RUN echo $(oc version)

# Install odo
RUN wget -O /tmp/odo.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/odo/${ODO_VERSION}/odo-linux-amd64.tar.gz \
    && cd /usr/bin && tar -xvzf /tmp/odo.tar.gz && chmod a+x /usr/bin/odo && rm -f /tmp/odo.tar.gz
RUN echo $(odo version)

# Install knative cli
RUN wget -O /tmp/kn.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/serverless/${KN_VERSION}/kn-linux-amd64-${KN_VERSION}.tar.gz \
    && cd /usr/bin && tar -xvzf /tmp/kn.tar.gz ./kn && chmod a+x kn && rm -f /tmp/kn.tar.gz
RUN echo $(kn version)

# Install tekton cli
RUN wget -O /tmp/tkn.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/${TKN_VERSION}/tkn-linux-amd64-${TKN_VERSION}.tar.gz \
    && cd /usr/bin && tar -xvzf /tmp/tkn.tar.gz ./tkn && chmod a+x tkn && rm -f /tmp/tkn.tar.gz
RUN echo $(tkn version)

# Install gitops cli
RUN wget -O /tmp/kam.tar.gz https://github.com/redhat-developer/kam/archive/${KAM_VERSION}.tar.gz \
    && cd /usr/bin && tar -xvzf /tmp/kam.tar.gz ./kam && chmod a+x kam && rm -f /tmp/kam.tar.gz
RUN echo $(kam version)

# add developer user and configure it
RUN mkdir -p /projects && \
    useradd -u 1000 -G wheel,root -d /home/developer --shell /bin/zsh -m developer && \
    mkdir -p /home/developer && cat /etc/passwd | \
    sed s#developer:x.*#developer:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/zsh#g \
    > /home/developer/passwd.template && \
    cat /etc/group | \
    sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g \
    > /home/developer/group.template && \
    echo "developer	ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers && \
    for f in "/home/developer" "/etc/passwd" "/etc/group" "/projects"; do \
      chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done
ADD entrypoint.sh ${HOME}/
RUN chmod +x ${HOME}/*.sh

# oh-my-zsh
RUN dnf install -y zsh
RUN sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
RUN sed -i -e 's|ZSH_THEME="robbyrussell"|ZSH_THEME="eastwood"|g' ~/.zshrc

# Remove artifacts and modules
RUN [ ! -d /tmp/scripts ] || rm -rf /tmp/scripts
RUN [ ! -d /tmp/artifacts ] || rm -rf /tmp/artifacts
# Clear package manager metadata
RUN dnf clean all && [ ! -d /var/cache/yum ] || rm -rf /var/cache/yum

USER developer
ENTRYPOINT ["/home/developer/entrypoint.sh"]
WORKDIR /projects
CMD tail -f /dev/null

# metadata
ENV SUMMARY="Red Hat CodeReady Workspaces - Quay dev stack on Fedora 32" \
    DESCRIPTION="Red Hat CodeReady Workspaces - Quay dev stack on Fedora 32"

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      maintainer="Adnan Drina <adnan.drina@gmail.com>"
