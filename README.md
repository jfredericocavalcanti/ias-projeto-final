# Atividade Final — Terraform + Ansible Roles + Docker

Segundo projeto de Infraestrutura como Código, com uma estrutura diferente do projeto anterior.

## Objetivo

Demonstrar:

- Terraform sem utilização de módulos;
- Provisionamento de uma infraestrutura AWS simples;
- Ansible organizado com **Roles**;
- Separação entre configuração do Docker e configuração da aplicação;
- Ansible Vault para informações sensíveis;
- Docker para execução da aplicação;
- Validação da aplicação após o deploy;
- Idempotência.

## Arquitetura

```text
Internet
   |
   v
Internet Gateway
   |
   v
VPC 172.20.0.0/16
   |
   v
Subnet pública
   |
   v
Security Group
  |-- TCP 22
  `-- TCP 3000
   |
   v
EC2 t3.micro
   |
   +-- Role docker
   |     +-- instala Docker
   |     +-- habilita serviço
   |     `-- inicia Docker
   |
   `-- Role application
         +-- prepara aplicação
         +-- baixa imagem
         +-- cria container
         `-- valida HTTP
```

## Estrutura

```text
projeto-2-terraform-ansible-roles/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── backend.tf
│   ├── vpc.tf
│   ├── security_group.tf
│   ├── key_pair.tf
│   ├── ec2.tf
│   └── outputs.tf
│
├── ansible/
│   ├── site.yml
│   ├── requirements.yml
│   ├── inventory/
│   │   └── hosts.yml
│   ├── group_vars/
│   │   └── all/
│   │       └── vault.yml.example
│   └── roles/
│       ├── docker/
│       │   ├── tasks/main.yml
│       │   ├── handlers/main.yml
│       │   └── defaults/main.yml
│       └── application/
│           ├── tasks/main.yml
│           └── defaults/main.yml
│
├── scripts/
│   └── deploy-ansible.sh
│
├── .gitignore
└── README.md
```

## Requisitos

- AWS CLI configurada;
- Terraform >= 1.5;
- Ansible;
- Python 3;
- SSH;
- WSL/Linux/macOS;
- chave SSH local;
- bucket S3 para o backend, se o backend remoto for utilizado.

## 1. Preparar a chave

```bash
ls -la ~/.ssh/
```

Se não existir:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

Nunca versione a chave privada.

## 2. Instalar a coleção Ansible

Na raiz:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

## 3. Configurar o Vault

Copie o exemplo:

```bash
cp ansible/group_vars/all/vault.yml.example ansible/group_vars/all/vault.yml
```

Edite os valores e criptografe:

```bash
ansible-vault encrypt ansible/group_vars/all/vault.yml
```

Para editar posteriormente:

```bash
ansible-vault edit ansible/group_vars/all/vault.yml
```

Para execução sem digitar a senha a cada vez:

```bash
printf '%s\n' 'SUA_SENHA' > ansible/group_vars/all/vault-password.txt
export ANSIBLE_VAULT_PASSWORD_FILE="$PWD/ansible/group_vars/all/vault-password.txt"
```

O arquivo `vault-password.txt` está no `.gitignore`.

## 4. Terraform

```bash
cd terraform
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Use o workspace `dev`:

```bash
terraform workspace select dev || terraform workspace new dev
```

## 5. Deploy

No diretório `terraform`:

```bash
terraform apply
```

O Terraform:

1. cria a infraestrutura;
2. cria a EC2;
3. obtém o IP público;
4. gera/atualiza o inventário;
5. chama o script de integração;
6. o script executa o Ansible;
7. a Role `docker` instala e inicia o Docker;
8. a Role `application` cria o container;
9. o Ansible valida a aplicação.

O `local-exec` é utilizado somente como mecanismo de integração. A configuração da EC2 fica no Ansible.

## 6. Testar a aplicação

```bash
terraform output public_ip
```

Acesse:

```text
http://IP_PUBLICO:3000
```

Ou:

```bash
curl http://$(terraform output -raw public_ip):3000
```

## 7. Testar o container

```bash
ssh -i ~/.ssh/id_rsa ec2-user@IP_PUBLICO
docker ps
```

O container esperado é:

```text
cloud-lab-02-app
```

## 8. Testar idempotência

Execute novamente:

```bash
ansible-playbook \
  --ask-vault-pass \
  -i ansible/inventory/hosts.yml \
  ansible/site.yml
```

A execução não deve apresentar alterações desnecessárias.

Também execute:

```bash
terraform apply
```

sem alterar a infraestrutura.

## 9. Destruir

Depois de coletar as evidências:

```bash
terraform destroy
```

## Segurança

Para facilitar o laboratório acadêmico, o Security Group pode utilizar:

```text
0.0.0.0/0
```

Isso não é recomendado para produção. Em ambiente real, a porta 22 deve ser restrita ao IP autorizado.

Nunca versione:

- chave privada SSH;
- senha do Vault;
- credenciais AWS;
- arquivos de secrets em texto claro.

## Checklist

- [ ] Terraform sem módulos.
- [ ] VPC criada pelo Terraform.
- [ ] Subnet pública criada pelo Terraform.
- [ ] Security Group configurado.
- [ ] EC2 `t3.micro`.
- [ ] Workspace `dev`.
- [ ] Ansible utilizando Roles.
- [ ] Role `docker`.
- [ ] Role `application`.
- [ ] Docker instalado pelo Ansible.
- [ ] Container gerenciado pelo Ansible.
- [ ] Ansible Vault configurado.
- [ ] Validação HTTP executada pelo Ansible.
- [ ] Aplicação acessível na porta 3000.
- [ ] Idempotência testada.
- [ ] `terraform destroy` executado.
- [ ] Nenhuma credencial no Git.

