FROM archlinux:base-devel
RUN pacman -Syu --noconfirm

# setup user, needed for AUR  
RUN useradd -m -G wheel archuser
RUN echo "archuser:password" | chpasswd 
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER archuser
WORKDIR /home/archuser

# setup data-synthesizer
COPY ./data-synthesizer ./data-synthesizer
RUN sudo chown -R archuser:archuser data-synthesizer
RUN sudo pacman -S --noconfirm git
RUN git clone https://aur.archlinux.org/godot-headless-bin.git; cd godot-headless-bin; makepkg -s; sudo pacman -U --noconfirm godot-headless*.pkg.tar.zst; cd ..; rm -rf godot-headless-bin 

# setup adapter
COPY ./adapter ./adapter
RUN sudo chown -R archuser:archuser adapter
RUN sudo pacman -S --noconfirm python
RUN cd adapter; python -m venv venv;  ./venv/bin/pip install -r requirements.txt

