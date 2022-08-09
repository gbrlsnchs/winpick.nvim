FROM docker.io/debian

RUN \
	apt update --yes && \
	apt install --yes curl git && \
	curl --location https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb --output nvim.deb && \
	git clone https://github.com/nvim-lua/plenary.nvim && \
	apt install ./nvim.deb


COPY . winpick.nvim
WORKDIR winpick.nvim

CMD ["./scripts/test.sh"]
