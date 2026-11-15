# Current Ubuntu LTS, pinned by its YY.04 tag (Resolute Raccoon, April 2026).
FROM ubuntu:26.04

ARG USERNAME=dev
ARG UID=1000
ARG GID=1000

# Add the outer shell the existing terminal profile execs before `nix develop`
# (often zsh). Do not apt-install the toolchain.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      sudo \
      xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && if getent passwd ubuntu >/dev/null; then userdel -r ubuntu; fi \
    && if getent group ubuntu >/dev/null; then groupdel ubuntu || true; fi \
    && if getent group users >/dev/null; then groupdel users; fi \
    && groupadd --gid "${GID}" "${USERNAME}" \
    && useradd --uid "${UID}" --gid "${GID}" --create-home --shell /bin/bash "${USERNAME}" \
    && install -d -m 0755 /opt/devcontainer /etc/nix \
    && echo "${USERNAME} ALL=(root) NOPASSWD: /opt/devcontainer/realize.sh ${USERNAME}, /opt/devcontainer/realize.sh ${USERNAME} private" \
      > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

COPY nix-access.sh /opt/devcontainer/nix-access.sh
COPY realize.sh /opt/devcontainer/realize.sh
COPY git-identity.sh /opt/devcontainer/git-identity.sh
COPY gpu-link.sh /opt/devcontainer/gpu-link.sh
COPY install-nix.sh /opt/devcontainer/install-nix.sh
COPY nix-profile.sh /etc/profile.d/nix-profile.sh
COPY nix.conf /etc/nix/nix.conf
COPY nix-wrapper.sh /usr/local/bin/nix
RUN chmod 0755 /opt/devcontainer/nix-access.sh /opt/devcontainer/realize.sh \
      /opt/devcontainer/git-identity.sh /opt/devcontainer/gpu-link.sh \
      /opt/devcontainer/install-nix.sh \
      /usr/local/bin/nix \
    && ln -s nix /usr/local/bin/nix-shell \
    && chmod 0644 /etc/profile.d/nix-profile.sh /etc/nix/nix.conf

USER ${USERNAME}
WORKDIR /workspace
